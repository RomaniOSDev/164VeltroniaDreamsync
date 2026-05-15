import SwiftUI

struct SettingsRowCell: View {
    let title: String
    let icon: String
    var iconColor: Color = .appPrimary
    var titleColor: Color = .appTextPrimary
    var showChevron: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                IconBadge(icon: icon, color: iconColor, size: 40)
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(titleColor)
                Spacer()
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
        }
        .buttonStyle(LightTapButtonStyle())
    }
}

struct QuickLinkCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            FeedbackService.lightTap()
            action()
        }) {
            HStack(spacing: 14) {
                IconBadge(icon: icon, color: .appPrimary, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.appAccent)
            }
            .padding(16)
            .appSurface(elevation: .medium, accent: .appPrimary, tintStrength: 0.05)
        }
        .buttonStyle(LightTapButtonStyle())
    }
}

struct StatMetricTile: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            IconBadge(icon: icon, color: .appAccent, size: 40)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .appInsetSurface()
    }
}
