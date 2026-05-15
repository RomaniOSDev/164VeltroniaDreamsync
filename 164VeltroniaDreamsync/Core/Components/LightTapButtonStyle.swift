import SwiftUI

struct LightTapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                if pressed { FeedbackService.lightTap() }
            }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background(AppGradients.primaryButton)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppGradients.borderHighlight, lineWidth: 1)
            }
            .compositingGroup()
            .shadow(color: Color.appPrimary.opacity(0.35), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                if pressed { FeedbackService.lightTap() }
            }
    }
}
