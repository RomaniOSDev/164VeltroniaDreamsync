import SwiftUI

struct FocusPresetCard: View {
    let preset: TimerPreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    IconBadge(
                        icon: preset.iconName,
                        color: isSelected ? .appPrimary : .appAccent,
                        size: 36
                    )
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.appPrimary)
                    }
                }
                Text(preset.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(preset.subtitle)
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(14)
            .frame(width: 130, alignment: .leading)
            .appSurface(
                cornerRadius: 16,
                elevation: isSelected ? .medium : .flat,
                accent: isSelected ? .appPrimary : nil,
                tintStrength: isSelected ? 0.1 : 0
            )
        }
        .buttonStyle(LightTapButtonStyle())
    }
}
