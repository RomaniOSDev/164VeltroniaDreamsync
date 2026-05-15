import SwiftUI

struct HomeGoalWidgetCard: View {
    let imageName: String
    let title: String
    let subtitle: String
    let current: Int
    let goal: Int
    let accent: Color
    let action: () -> Void

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1)
    }

    var body: some View {
        Button(action: {
            FeedbackService.lightTap()
            action()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 72)
                        .clipped()

                    LinearGradient(
                        colors: [.clear, Color.appBackground.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 72)

                    Text(title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(10)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)

                    HStack {
                        Text("\(current)/\(goal)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(progress >= 1 ? Color.appPrimary : Color.appTextPrimary)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(accent)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.appBackground)
                            Capsule()
                                .fill(AppGradients.accentBar)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(12)
            }
            .appSurface(
                cornerRadius: 16,
                elevation: progress >= 1 ? .medium : .flat,
                accent: accent,
                tintStrength: progress >= 1 ? 0.08 : 0.04
            )
        }
        .buttonStyle(LightTapButtonStyle())
    }
}
