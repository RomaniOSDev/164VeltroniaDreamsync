import SwiftUI

struct HomeInsightWidget: View {
    let imageName: String
    let value: String
    let label: String
    let icon: String
    var action: (() -> Void)?

    var body: some View {
        Group {
            if let action {
                Button(action: {
                    FeedbackService.lightTap()
                    action()
                }) { content }
                .buttonStyle(LightTapButtonStyle())
            } else {
                content
            }
        }
    }

    private var content: some View {
        HStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.caption2)
                        .foregroundStyle(Color.appAccent)
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .appSurface(cornerRadius: 16, elevation: .flat, accent: .appAccent, tintStrength: 0.04)
    }
}

struct HomeShortcutWidget: View {
    let imageName: String
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            FeedbackService.lightTap()
            action()
        }) {
            ZStack(alignment: .bottomLeading) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(minHeight: 120)
                    .clipped()

                LinearGradient(
                    colors: [.clear, Color.appBackground.opacity(0.3), Color.appBackground.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: icon)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appAccent)
                            .padding(8)
                            .background(Circle().fill(Color.appSurface.opacity(0.9)))
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                }
                .padding(14)
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppGradients.borderStroke(accent: .appAccent), lineWidth: 1)
            }
            .compositingGroup()
            .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
        }
        .buttonStyle(LightTapButtonStyle())
    }
}
