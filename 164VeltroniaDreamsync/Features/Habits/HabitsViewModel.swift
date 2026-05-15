import Combine
import Foundation

@MainActor
final class HabitsViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var editingHabit: HabitItem?
    @Published var pulseHabitID: UUID?
    @Published var showSuccessOverlay = false
    @Published var searchText = ""
    @Published var selectedGroup: HabitGroup?

    private let store: AppDataStore
    private let bannerManager: AchievementBannerManager
    private var cancellables = Set<AnyCancellable>()

    init(store: AppDataStore, bannerManager: AchievementBannerManager) {
        self.store = store
        self.bannerManager = bannerManager
        store.resetDailyHabitsIfNeeded()
        store.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var habits: [HabitItem] {
        var items = store.habits.filter(\.isScheduledToday)
        if let selectedGroup {
            items = items.filter { $0.group == selectedGroup }
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            items = items.filter { store.matchesSearch($0, query: searchText) }
        }
        return items.sorted { $0.title < $1.title }
    }

    var hasHabits: Bool { !store.habits.isEmpty }

    func toggleHabit(_ habit: HabitItem) {
        let checkedIn = store.toggleHabitCheckIn(id: habit.id)
        if checkedIn {
            FeedbackService.habitCheckIn()
            pulseHabitID = habit.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.pulseHabitID = nil }
            SuccessOverlayHelper.trigger { self.showSuccessOverlay = $0 }
            processAchievements()
        } else {
            FeedbackService.lightTap()
        }
    }

    func saveHabit(_ habit: HabitItem) {
        if store.habits.contains(where: { $0.id == habit.id }) {
            store.updateHabit(habit)
        } else {
            store.addHabit(title: habit.title, group: habit.group, scheduledWeekdays: habit.scheduledWeekdays)
        }
        FeedbackService.success()
        processAchievements()
    }

    func deleteHabit(_ habit: HabitItem) {
        store.deleteHabit(id: habit.id)
        FeedbackService.mediumAction()
    }

    private func processAchievements() {
        for achievement in store.evaluateAchievements() {
            FeedbackService.achievementUnlocked()
            bannerManager.enqueue(title: achievement.title, message: achievement.description)
        }
    }
}
