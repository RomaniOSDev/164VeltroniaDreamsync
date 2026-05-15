import SwiftUI

struct HomeAchievementWidget: View {
    @EnvironmentObject private var store: AppDataStore

    private var unlockedCount: Int { store.achievementsUnlocked.count }
    private var totalCount: Int { AchievementDefinition.all.count }

    var body: some View {
        AppCard(accent: .appAccent) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.appAccent.opacity(0.2))
                        .frame(width: 56, height: 56)
                    Image(systemName: nextAchievementIcon)
                        .font(.title2)
                        .foregroundStyle(Color.appAccent)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Achievements")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("\(unlockedCount) of \(totalCount) unlocked")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    if let next = store.nextLockedAchievement {
                        Text("Next: \(next.title)")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Color.appPrimary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.appBackground, lineWidth: 6)
                        .frame(width: 48, height: 48)
                    Circle()
                        .trim(from: 0, to: achievementProgress)
                        .stroke(Color.appPrimary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(-90))
                    Text("\(unlockedCount)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
        }
    }

    private var achievementProgress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalCount)
    }

    private var nextAchievementIcon: String {
        store.nextLockedAchievement?.iconName ?? "star.fill"
    }
}
