import SwiftUI

struct MetaTag: View {
    let text: String
    var icon: String?
    var style: MetaTagStyle = .neutral

    enum MetaTagStyle {
        case neutral, accent, warning, primary

        var foreground: Color {
            switch self {
            case .neutral: return .appTextSecondary
            case .accent: return .appAccent
            case .warning: return .red
            case .primary: return .appPrimary
            }
        }

        var background: Color {
            switch self {
            case .neutral: return .appBackground.opacity(0.6)
            case .accent: return .appAccent.opacity(0.15)
            case .warning: return .red.opacity(0.15)
            case .primary: return .appPrimary.opacity(0.15)
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .semibold))
            }
            Text(text)
                .font(.caption2.weight(.medium))
                .lineLimit(1)
        }
        .foregroundStyle(style.foreground)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(style.background)
        .clipShape(Capsule())
    }
}
