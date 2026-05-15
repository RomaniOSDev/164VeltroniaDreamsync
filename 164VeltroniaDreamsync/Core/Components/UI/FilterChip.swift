import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isSelected ? Color.appTextPrimary : Color.appTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background {
                    if isSelected {
                        Capsule(style: .continuous).fill(AppGradients.primaryButton)
                    } else {
                        Capsule(style: .continuous).fill(AppGradients.surface)
                    }
                }
                .overlay {
                    Capsule(style: .continuous)
                        .stroke(
                            isSelected ? Color.clear : Color.appTextPrimary.opacity(0.08),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(LightTapButtonStyle())
    }
}
