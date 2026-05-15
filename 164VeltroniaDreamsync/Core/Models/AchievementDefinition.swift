import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_task",
            title: "First Task",
            description: "Completed your first task.",
            iconName: "checkmark.circle.fill"
        ),
        AchievementDefinition(
            id: "focus_pro",
            title: "Focus Pro",
            description: "Completed 10 focus sessions.",
            iconName: "timer"
        ),
        AchievementDefinition(
            id: "habit_newbie",
            title: "Habit Newbie",
            description: "Checked in with a habit for the first time.",
            iconName: "leaf.fill"
        ),
        AchievementDefinition(
            id: "consistent_checker",
            title: "Consistent Checker",
            description: "Maintained a habit check-in streak for 3 days.",
            iconName: "flame.fill"
        ),
        AchievementDefinition(
            id: "productivity_guru",
            title: "#ProductivityGuru",
            description: "Reached a total of 100 completed tasks.",
            iconName: "star.fill"
        ),
        AchievementDefinition(
            id: "session_expert",
            title: "Session Expert",
            description: "Accrued a total of 500 minutes in focused sessions.",
            iconName: "clock.fill"
        ),
        AchievementDefinition(
            id: "habit_devotee",
            title: "Habit Devotee",
            description: "Completed check-ins for three different habits.",
            iconName: "person.3.fill"
        ),
        AchievementDefinition(
            id: "routine_master",
            title: "Routine Master",
            description: "Sustained a habit streak for one week.",
            iconName: "crown.fill"
        ),
        AchievementDefinition(
            id: "week_streak",
            title: "7-Day Streak",
            description: "Maintained a 7-day activity streak.",
            iconName: "calendar.badge.checkmark"
        ),
        AchievementDefinition(
            id: "first_focus_week",
            title: "First Focus Week",
            description: "Completed 7 focus sessions in one week.",
            iconName: "scope"
        ),
        AchievementDefinition(
            id: "habits_fifty",
            title: "Habit Champion",
            description: "Logged 50 habit check-ins.",
            iconName: "hands.clap.fill"
        )
    ]
}
