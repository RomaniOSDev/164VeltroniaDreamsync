import SwiftUI

struct DailyGoalProgressView: View {
    let title: String
    let current: Int
    let goal: Int
    let icon: String

    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1)
    }

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(icon: icon, color: progress >= 1 ? .appPrimary : .appAccent, size: 40)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Text("\(current)/\(goal)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(progress >= 1 ? Color.appPrimary : Color.appTextSecondary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.appBackground)
                        Capsule()
                            .fill(AppGradients.accentBar)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 8)
            }
        }
    }
}
