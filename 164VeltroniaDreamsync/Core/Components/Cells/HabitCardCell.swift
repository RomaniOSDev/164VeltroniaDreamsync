import SwiftUI

struct HabitCardCell: View {
    let habit: HabitItem
    let isCompleted: Bool
    let onToggle: () -> Void
    var isPulsing: Bool = false
    var onJournal: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(icon: habit.group.iconName, color: isCompleted ? .appPrimary : .appAccent, size: 50)

            VStack(alignment: .leading, spacing: 8) {
                Text(habit.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    MetaTag(text: habit.group.rawValue, style: .neutral)
                    MetaTag(text: "\(habit.streak) day streak", icon: "flame.fill", style: .primary)
                    if !habit.scheduledWeekdays.isEmpty {
                        MetaTag(text: scheduleLabel, icon: "calendar", style: .accent)
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.clock")
                    Text("View journal")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
            }

            Spacer(minLength: 0)

            CheckInButton(isCompleted: isCompleted, action: onToggle)
        }
        .padding(16)
        .appCellSurface(
            accent: isCompleted ? .appPrimary : (isPulsing ? .appAccent : nil),
            tintStrength: isCompleted ? 0.1 : (isPulsing ? 0.06 : 0)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isPulsing ? Color.appAccent : .clear, lineWidth: 2)
        }
        .scaleEffect(isPulsing ? 1.015 : 1)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isPulsing)
    }

    private var scheduleLabel: String {
        let symbols = Calendar.current.shortWeekdaySymbols
        return habit.scheduledWeekdays.map { symbols[$0 - 1] }.joined(separator: " ")
    }
}

private struct CheckInButton: View {
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(isCompleted ? Color.appPrimary : Color.appTextSecondary.opacity(0.4), lineWidth: 2)
                    .frame(width: 44, height: 44)
                if isCompleted {
                    Circle()
                        .fill(AppGradients.primaryButton)
                        .frame(width: 44, height: 44)
                    Image(systemName: "checkmark")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
        }
        .buttonStyle(LightTapButtonStyle())
    }
}
