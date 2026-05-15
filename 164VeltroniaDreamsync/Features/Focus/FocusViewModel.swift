import Combine
import Foundation
import SwiftUI

enum FocusTimerPhase {
    case idle
    case focus
    case breakTime
}

@MainActor
final class FocusViewModel: ObservableObject {
    @Published var phase: FocusTimerPhase = .idle
    @Published var isRunning = false
    @Published var remainingSeconds: Int = 0
    @Published var timerScale: CGFloat = 1
    @Published var showSettings = false
    @Published var showSuccessOverlay = false

    private let store: AppDataStore
    private let bannerManager: AchievementBannerManager
    private var endDate: Date?
    private(set) var totalPhaseSeconds: Int = 0
    private var tickCancellable: AnyCancellable?

    init(store: AppDataStore, bannerManager: AchievementBannerManager) {
        self.store = store
        self.bannerManager = bannerManager
        resetToFocusDuration()
    }

    var visibleSessions: [FocusSessionRecord] {
        store.pastSessions.filter { !$0.archived }
    }

    var progress: Double {
        guard totalPhaseSeconds > 0 else { return 0 }
        let current = displayRemainingSeconds(at: Date())
        return 1 - Double(current) / Double(totalPhaseSeconds)
    }

    var headerTitle: String {
        switch phase {
        case .idle: return "Current Focus Session"
        case .focus: return "Current Focus Session"
        case .breakTime: return "Break Time"
        }
    }

    var primaryButtonTitle: String {
        if phase == .idle { return "Start" }
        return isRunning ? "Pause" : "Resume"
    }

    func displayRemainingSeconds(at date: Date) -> Int {
        if isRunning, let end = endDate {
            return max(0, Int(end.timeIntervalSince(date).rounded(.down)))
        }
        return remainingSeconds
    }

    func formattedTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    func toggleTimer() {
        if phase == .idle {
            startFocus()
        } else if isRunning {
            pause()
        } else {
            resume()
        }
    }

    func syncTick(now: Date = Date()) {
        guard isRunning, let end = endDate else { return }
        let left = max(0, Int(end.timeIntervalSince(now).rounded(.down)))
        if remainingSeconds != left {
            remainingSeconds = left
        }
        if left <= 0 {
            completeCurrentPhase()
        }
    }

    func pause() {
        guard let end = endDate else { return }
        remainingSeconds = max(0, Int(end.timeIntervalSinceNow.rounded(.down)))
        endDate = nil
        isRunning = false
        stopTicking()
        FeedbackService.lightTap()
    }

    func resume() {
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        isRunning = true
        startTicking()
        syncTick()
        FeedbackService.lightTap()
    }

    func archiveSession(_ session: FocusSessionRecord) {
        store.archiveSession(id: session.id)
        FeedbackService.lightTap()
    }

    func applySettings() {
        if phase == .idle {
            resetToFocusDuration()
        }
    }

    func handleScenePhase(_ phase: ScenePhase) {
        if phase != .active, isRunning {
            pause()
        }
    }

    private func startFocus() {
        phase = .focus
        totalPhaseSeconds = max(store.focusDurationMin * 60, 60)
        remainingSeconds = totalPhaseSeconds
        endDate = Date().addingTimeInterval(TimeInterval(totalPhaseSeconds))
        isRunning = true
        startTicking()
        syncTick()
        FeedbackService.mediumAction()
    }

    private func startBreak() {
        phase = .breakTime
        totalPhaseSeconds = max(store.breakDurationMin * 60, 60)
        remainingSeconds = totalPhaseSeconds
        endDate = Date().addingTimeInterval(TimeInterval(totalPhaseSeconds))
        isRunning = true
        startTicking()
        syncTick()
    }

    private func completeCurrentPhase() {
        stopTicking()
        isRunning = false
        endDate = nil

        switch phase {
        case .focus:
            FeedbackService.focusSessionComplete()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                timerScale = 1.15
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { self.timerScale = 1 }
            }
            store.completeFocusSession(durationMinutes: store.focusDurationMin)
            SuccessOverlayHelper.trigger { self.showSuccessOverlay = $0 }
            processAchievements()
            startBreak()
        case .breakTime:
            phase = .idle
            resetToFocusDuration()
            FeedbackService.success()
        case .idle:
            break
        }
    }

    private func resetToFocusDuration() {
        totalPhaseSeconds = max(store.focusDurationMin * 60, 60)
        remainingSeconds = totalPhaseSeconds
    }

    private func startTicking() {
        stopTicking()
        tickCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                self?.syncTick(now: date)
            }
    }

    private func stopTicking() {
        tickCancellable?.cancel()
        tickCancellable = nil
    }

    private func processAchievements() {
        for achievement in store.evaluateAchievements() {
            FeedbackService.achievementUnlocked()
            bannerManager.enqueue(title: achievement.title, message: achievement.description)
        }
    }
}
