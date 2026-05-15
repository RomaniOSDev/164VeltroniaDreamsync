import Foundation

extension AppDataStore {
    var focusMinutesToday: Int {
        let calendar = Calendar.current
        return pastSessions
            .filter { !$0.archived && calendar.isDateInToday($0.completedAt) }
            .reduce(0) { $0 + $1.durationMinutes }
    }

    var overallDailyProgress: Double {
        let tasks = min(Double(tasksCompletedToday) / Double(max(dailyTaskGoal, 1)), 1)
        let focus = min(Double(focusSessionsToday) / Double(max(dailyFocusGoal, 1)), 1)
        let habits = min(Double(habitCheckInsToday) / Double(max(dailyHabitGoal, 1)), 1)
        return (tasks + focus + habits) / 3
    }

    var upNextTasks: [TaskItem] {
        activeTasks
            .sorted { lhs, rhs in
                if lhs.isOverdue != rhs.isOverdue { return lhs.isOverdue }
                if lhs.isFlagged != rhs.isFlagged { return lhs.isFlagged }
                if lhs.isDueToday != rhs.isDueToday { return lhs.isDueToday }
                return lhs.priority.sortOrder < rhs.priority.sortOrder
            }
            .prefix(4)
            .map { $0 }
    }

    var habitsDueToday: [HabitItem] {
        habitsVisibleToday
            .sorted { !$0.completedToday && $1.completedToday }
    }

    var nextLockedAchievement: AchievementDefinition? {
        AchievementDefinition.all.first { !isAchievementUnlocked($0.id) }
    }

    var recentFocusSession: FocusSessionRecord? {
        pastSessions.first { !$0.archived }
    }
}
