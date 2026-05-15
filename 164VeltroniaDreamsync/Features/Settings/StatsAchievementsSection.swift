import SwiftUI

struct StatsAchievementsSection: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(
                title: "Achievements",
                subtitle: "\(store.achievementsUnlocked.count) of \(AchievementDefinition.all.count) unlocked"
            )

            AppCard {
                VStack(alignment: .leading, spacing: 10) {
                    metricRow("Tasks completed", value: "\(store.tasksCompleted)", icon: "checkmark.circle")
                    metricRow("Focus minutes", value: "\(store.totalMinutesUsed)", icon: "timer")
                    metricRow("Habit check-ins", value: "\(store.habitCheckIns)", icon: "leaf")
                    metricRow("Longest streak", value: "\(store.longestStreak) days", icon: "flame.fill")
                }
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AchievementDefinition.all) { achievement in
                    AchievementCardCell(
                        achievement: achievement,
                        isUnlocked: store.isAchievementUnlocked(achievement.id)
                    )
                }
            }
        }
    }

    private func metricRow(_ label: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.appAccent)
                .frame(width: 20)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
        }
    }
}
