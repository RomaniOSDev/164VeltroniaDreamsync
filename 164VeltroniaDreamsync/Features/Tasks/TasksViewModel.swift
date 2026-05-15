import Combine
import Foundation

@MainActor
final class TasksViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var showTemplatesSheet = false
    @Published var showFilterSheet = false
    @Published var editingTask: TaskItem?
    @Published var templateDraft: TaskDraft?
    @Published var pulseTaskID: UUID?
    @Published var showSuccessOverlay = false
    @Published var searchText = ""
    @Published var isSelectionMode = false
    @Published var selectedIDs: Set<UUID> = []
    @Published var undoTask: TaskItem?
    @Published var showUndoToast = false

    private let store: AppDataStore
    private let bannerManager: AchievementBannerManager
    private var cancellables = Set<AnyCancellable>()
    private var undoWorkItem: DispatchWorkItem?

    init(store: AppDataStore, bannerManager: AchievementBannerManager) {
        self.store = store
        self.bannerManager = bannerManager
        store.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var smartList: TaskSmartList {
        TaskSmartList(rawValue: store.selectedSmartList) ?? .all
    }

    var filteredActiveTasks: [TaskItem] {
        var items = store.activeTasks
        if store.selectedCategoryFilter != "All" {
            items = items.filter { $0.category.rawValue == store.selectedCategoryFilter }
        }
        if store.showFlaggedOnly {
            items = items.filter(\.isFlagged)
        }
        if smartList != .all {
            items = items.filter { store.matchesSmartList($0, list: smartList) }
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            items = items.filter { store.matchesSearch($0, query: searchText) }
        }
        items.sort { lhs, rhs in
            if store.sortByDueDate {
                switch (lhs.dueDate, rhs.dueDate) {
                case let (left?, right?):
                    if left != right {
                        return store.isAscendingSort ? left < right : left > right
                    }
                case (nil, .some): return false
                case (.some, nil): return true
                case (nil, nil): break
                }
            }
            if lhs.priority.sortOrder != rhs.priority.sortOrder {
                return store.isAscendingSort
                    ? lhs.priority.sortOrder < rhs.priority.sortOrder
                    : lhs.priority.sortOrder > rhs.priority.sortOrder
            }
            return store.isAscendingSort ? lhs.sortOrder < rhs.sortOrder : lhs.sortOrder > rhs.sortOrder
        }
        return items
    }

    var completedTasks: [TaskItem] {
        store.tasks.filter(\.completed).sorted { ($0.completedAt ?? $0.createdAt) > ($1.completedAt ?? $1.createdAt) }
    }

    var hasActiveTasks: Bool { !store.activeTasks.isEmpty }

    func refresh() {
        store.processRecurringTasks()
    }

    func completeTask(_ task: TaskItem) {
        store.completeTask(id: task.id)
        FeedbackService.taskComplete()
        pulseTaskID = task.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.pulseTaskID = nil }
        SuccessOverlayHelper.trigger { self.showSuccessOverlay = $0 }
        processAchievements()
    }

    func archiveTask(_ task: TaskItem) {
        store.archiveTask(id: task.id)
        FeedbackService.mediumAction()
    }

    func deleteTask(_ task: TaskItem) {
        guard let snapshot = store.tasks.first(where: { $0.id == task.id }) else { return }
        store.deleteTask(id: task.id)
        FeedbackService.mediumAction()
        showUndo(for: snapshot)
    }

    func showUndo(for task: TaskItem) {
        undoWorkItem?.cancel()
        undoTask = task
        showUndoToast = true
        let work = DispatchWorkItem { [weak self] in
            self?.showUndoToast = false
            self?.undoTask = nil
        }
        undoWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: work)
    }

    func performUndo() {
        guard let task = undoTask else { return }
        store.restoreDeletedTask(task)
        undoTask = nil
        showUndoToast = false
        undoWorkItem?.cancel()
        FeedbackService.success()
    }

    func bulkCompleteSelected() {
        store.bulkComplete(ids: selectedIDs)
        selectedIDs.removeAll()
        isSelectionMode = false
        FeedbackService.success()
        processAchievements()
    }

    func bulkDeleteSelected() {
        for id in selectedIDs {
            if let task = store.tasks.first(where: { $0.id == id }) {
                deleteTask(task)
            }
        }
        selectedIDs.removeAll()
        isSelectionMode = false
    }

    func moveTasks(from source: IndexSet, to destination: Int) {
        store.moveTasks(from: source, to: destination, in: filteredActiveTasks)
    }

    func addTask(_ task: TaskItem) {
        store.addTask(task)
        FeedbackService.success()
        processAchievements()
    }

    func updateTask(_ task: TaskItem) {
        store.updateTask(task)
        store.processRecurringTasks()
        FeedbackService.success()
    }

    func addQuickTask(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        addTask(TaskItem(title: trimmed))
    }

    private func processAchievements() {
        for achievement in store.evaluateAchievements() {
            FeedbackService.achievementUnlocked()
            bannerManager.enqueue(title: achievement.title, message: achievement.description)
        }
    }
}
