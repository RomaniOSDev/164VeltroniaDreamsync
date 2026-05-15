import Foundation

struct DayStatPoint: Identifiable {
    let id: String
    let date: Date
    let tasksCompleted: Int
    let focusMinutes: Int
    let habitCheckIns: Int
}

enum StatsPeriod: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"

    var id: String { rawValue }
}

enum StatisticsService {
    static func chartData(store: AppDataStore, period: StatsPeriod) -> [DayStatPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayCount = period == .week ? 7 : 30
        guard let start = calendar.date(byAdding: .day, value: -(dayCount - 1), to: today) else {
            return []
        }

        return (0..<dayCount).compactMap { offset -> DayStatPoint? in
            guard let day = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            let next = calendar.date(byAdding: .day, value: 1, to: day) ?? day

            let tasksDone = store.tasks.filter { task in
                guard let completedAt = task.completedAt else { return false }
                return completedAt >= day && completedAt < next
            }.count

            let focusMin = store.pastSessions.filter { session in
                !session.archived && session.completedAt >= day && session.completedAt < next
            }.reduce(0) { $0 + $1.durationMinutes }

            var habitCount = 0
            for habit in store.habits {
                habitCount += habit.checkInDates.filter { $0 >= day && $0 < next }.count
            }

            return DayStatPoint(
                id: ISO8601DateFormatter().string(from: day),
                date: day,
                tasksCompleted: tasksDone,
                focusMinutes: focusMin,
                habitCheckIns: habitCount
            )
        }
    }

    static func weeklyReport(store: AppDataStore) -> (tasks: Int, focusMinutes: Int, habits: Int, bestStreak: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: today) else {
            return (0, 0, 0, store.longestStreak)
        }
        let next = calendar.date(byAdding: .day, value: 1, to: today) ?? today

        let tasksDone = store.tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return completedAt >= weekStart && completedAt < next
        }.count

        let focusMin = store.pastSessions.filter { session in
            !session.archived && session.completedAt >= weekStart && session.completedAt < next
        }.reduce(0) { $0 + $1.durationMinutes }

        var habitsDone = 0
        for habit in store.habits {
            habitsDone += habit.checkInDates.filter { $0 >= weekStart && $0 < next }.count
        }

        return (tasksDone, focusMin, habitsDone, store.longestStreak)
    }

    static func focusSessionsThisWeek(store: AppDataStore) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: today) else { return 0 }
        return store.pastSessions.filter { !$0.archived && $0.completedAt >= weekStart }.count
    }
}
