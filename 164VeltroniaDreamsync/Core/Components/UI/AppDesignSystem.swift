import SwiftUI

// MARK: - Elevation (single shadow layer max — list cells use .low with no shadow)

enum AppElevation {
  /// Border + gradient fill only — best for scrolling lists.
    case flat
    case low
    case medium
    case high
}

enum AppGradients {
    static let background = LinearGradient(
        colors: [.appBackground, .appSurface.opacity(0.35), .appBackground],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surface = LinearGradient(
        colors: [Color.appSurface, Color.appSurface.opacity(0.86)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButton = LinearGradient(
        colors: [.appPrimary, .appPrimary.opacity(0.82), .appAccent.opacity(0.9)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentBar = LinearGradient(
        colors: [.appAccent, .appPrimary],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let borderHighlight = LinearGradient(
        colors: [Color.white.opacity(0.14), Color.white.opacity(0.03), .clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let tabBar = LinearGradient(
        colors: [Color.appSurface.opacity(0.98), Color.appSurface.opacity(0.92)],
        startPoint: .top,
        endPoint: .bottom
    )

    static func surfaceTinted(accent: Color, strength: Double = 0.12) -> LinearGradient {
        LinearGradient(
            colors: [accent.opacity(strength + 0.04), Color.appSurface.opacity(0.9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func borderStroke(accent: Color? = nil) -> LinearGradient {
        LinearGradient(
            colors: [
                (accent ?? .appAccent).opacity(0.32),
                Color.appTextPrimary.opacity(0.07)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Surface modifier

private struct AppSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let elevation: AppElevation
    var accent: Color?
    var tintStrength: Double = 0

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background {
                if let accent, tintStrength > 0 {
                    shape.fill(AppGradients.surfaceTinted(accent: accent, strength: tintStrength))
                } else {
                    shape.fill(AppGradients.surface)
                }
            }
            .overlay { shape.stroke(AppGradients.borderStroke(accent: accent), lineWidth: 1) }
            .overlay { shape.stroke(AppGradients.borderHighlight, lineWidth: 1) }
            .modifier(AppShadowModifier(elevation: elevation, accent: accent))
    }
}

private struct AppShadowModifier: ViewModifier {
    let elevation: AppElevation
    var accent: Color?

    func body(content: Content) -> some View {
        switch elevation {
        case .flat, .low:
            content
        case .medium:
            content
                .compositingGroup()
                .shadow(color: .black.opacity(0.22), radius: 8, y: 4)
        case .high:
            content
                .compositingGroup()
                .shadow(color: .black.opacity(0.3), radius: 12, y: 5)
        }
    }
}

extension View {
    /// Cards, panels — one composited shadow.
    func appSurface(
        cornerRadius: CGFloat = 16,
        elevation: AppElevation = .medium,
        accent: Color? = nil,
        tintStrength: Double = 0
    ) -> some View {
        modifier(AppSurfaceModifier(
            cornerRadius: cornerRadius,
            elevation: elevation,
            accent: accent,
            tintStrength: tintStrength
        ))
    }

    /// List rows — gradient + border, no shadow (scroll-friendly).
    func appCellSurface(accent: Color? = nil, tintStrength: Double = 0) -> some View {
        appSurface(cornerRadius: 16, elevation: .low, accent: accent, tintStrength: tintStrength)
    }

    func appInsetSurface(cornerRadius: CGFloat = 12) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.appBackground.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.appTextPrimary.opacity(0.06), lineWidth: 1)
                )
        )
    }
}
