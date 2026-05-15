import Combine
import Foundation
import SwiftUI

struct AchievementBannerPayload: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
}

@MainActor
final class AchievementBannerManager: ObservableObject {
    @Published var currentBanner: AchievementBannerPayload?
    private var queue: [AchievementBannerPayload] = []
    private var isShowing = false

    func enqueue(title: String, message: String) {
        let payload = AchievementBannerPayload(title: title, message: message)
        if isShowing {
            queue.append(payload)
        } else {
            show(payload)
        }
    }

    private func show(_ payload: AchievementBannerPayload) {
        isShowing = true
        currentBanner = payload
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentBanner = nil
                }
                isShowing = false
                if let next = queue.first {
                    queue.removeFirst()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        self.show(next)
                    }
                }
            }
        }
    }
}
