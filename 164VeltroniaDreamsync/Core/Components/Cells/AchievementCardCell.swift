import SwiftUI

struct AchievementCardCell: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked
                            ? LinearGradient(
                                colors: [.appAccent.opacity(0.35), .appPrimary.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.appBackground.opacity(0.9), Color.appBackground.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: 52, height: 52)
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? Color.appAccent : Color.appTextSecondary.opacity(0.35))
            }
            Text(achievement.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(isUnlocked ? Color.appTextPrimary : Color.appTextSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
            if isUnlocked {
                MetaTag(text: "Unlocked", icon: "star.fill", style: .primary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 140)
        .appSurface(
            cornerRadius: 14,
            elevation: isUnlocked ? .medium : .flat,
            accent: isUnlocked ? .appAccent : nil,
            tintStrength: isUnlocked ? 0.08 : 0
        )
    }
}
