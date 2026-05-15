import Foundation

extension AppDataStore {
    var activeTasks: [TaskItem] {
        tasks.filter { !$0.completed && !$0.isArchived && !$0.isRecurringTemplate }
    }

    var archivedTasks: [TaskItem] {
        tasks.filter(\.isArchived).sorted { $0.createdAt > $1.createdAt }
    }

    var tasksCompletedToday: Int {
        let calendar = Calendar.current
        return tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return calendar.isDateInToday(completedAt)
        }.count
    }

    var focusSessionsToday: Int {
        let calendar = Calendar.current
        return pastSessions.filter { !$0.archived && calendar.isDateInToday($0.completedAt) }.count
    }

    var habitCheckInsToday: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return habits.reduce(0) { count, habit in
            count + habit.checkInDates.filter { calendar.isDateInToday($0) }.count
        }
    }

    var habitsVisibleToday: [HabitItem] {
        habits.filter(\.isScheduledToday)
    }

    var linkedFocusTask: TaskItem? {
        guard let id = focusLinkedTaskId else { return nil }
        return tasks.first { $0.id == id && !$0.completed && !$0.isArchived }
    }

    func processRecurringTasks() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        var updated = tasks

        for template in updated where template.isRecurringTemplate && template.recurrence != .none {
            let shouldSpawn: Bool
            switch template.recurrence {
            case .none: shouldSpawn = false
            case .daily: shouldSpawn = true
            case .weekly:
                shouldSpawn = template.recurringWeekdays.isEmpty || template.recurringWeekdays.contains(weekday)
            }

            guard shouldSpawn else { continue }

            let hasInstance = updated.contains { task in
                task.recurringParentId == template.id
                    && !task.isRecurringTemplate
                    && !task.completed
                    && !task.isArchived
                    && task.spawnedForDay.map { calendar.isDate($0, inSameDayAs: today) } == true
            }

            if !hasInstance {
                var instance = template
                instance.id = UUID()
                instance.isRecurringTemplate = false
                instance.recurringParentId = template.id
                instance.spawnedForDay = today
                instance.completed = false
                instance.completedAt = nil
                instance.isArchived = false
                instance.sortOrder = (updated.map(\.sortOrder).max() ?? -1) + 1
                if instance.dueDate == nil {
                    instance.dueDate = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: today)
                }
                updated.append(instance)
            }
        }

        if updated != tasks { tasks = updated }
    }

    func archiveTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isArchived = true
        recordMeaningfulActivity()
    }

    func unarchiveTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isArchived = false
    }

    func restoreDeletedTask(_ task: TaskItem) {
        var restored = task
        restored.sortOrder = (tasks.map(\.sortOrder).max() ?? -1) + 1
        tasks.append(restored)
    }

    func bulkComplete(ids: Set<UUID>) {
        for id in ids {
            completeTask(id: id)
        }
    }

    func bulkDelete(ids: Set<UUID>) {
        for id in ids {
            deleteTask(id: id)
        }
    }

    func matchesSearch(_ task: TaskItem, query: String) -> Bool {
        let q = query.lowercased()
        guard !q.isEmpty else { return true }
        if task.title.lowercased().contains(q) { return true }
        if task.notes.lowercased().contains(q) { return true }
        if task.category.rawValue.lowercased().contains(q) { return true }
        if task.tags.contains(where: { $0.lowercased().contains(q) }) { return true }
        return false
    }

    func matchesSearch(_ habit: HabitItem, query: String) -> Bool {
        let q = query.lowercased()
        guard !q.isEmpty else { return true }
        if habit.title.lowercased().contains(q) { return true }
        if habit.group.rawValue.lowercased().contains(q) { return true }
        return false
    }

    func matchesSmartList(_ task: TaskItem, list: TaskSmartList) -> Bool {
        switch list {
        case .all: return true
        case .dueToday: return task.isDueToday
        case .overdue: return task.isOverdue
        case .flagged: return task.isFlagged
        case .noDueDate: return task.dueDate == nil
        }
    }

    func applyTimerPreset(_ preset: TimerPreset) {
        selectedTimerPresetId = preset.id
        if preset.id != "custom" {
            focusDurationMin = preset.focusMinutes
            breakDurationMin = preset.breakMinutes
        }
    }

    func addHabit(
        title: String,
        group: HabitGroup = .other,
        scheduledWeekdays: [Int] = []
    ) {
        habits.append(HabitItem(title: title, group: group, scheduledWeekdays: scheduledWeekdays))
        recordMeaningfulActivity()
    }

    func updateHabit(_ habit: HabitItem) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index] = habit
        recordMeaningfulActivity()
    }

}
