import SwiftUI

struct TaskCardCell: View {
    let task: TaskItem
    var isSelected: Bool = false
    var showSelection: Bool = false
    var isPulsing: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            if showSelection {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.appPrimary : Color.appTextSecondary)
                    .padding(.top, 10)
            }

            IconBadge(icon: task.category.iconName, color: priorityColor, size: 48)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 6) {
                    if task.isFlagged {
                        Image(systemName: "flag.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appPrimary)
                    }
                    Text(task.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    Spacer(minLength: 0)
                }

                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                }

                FlowLayoutTags(task: task)
            }

            priorityIndicator
        }
        .padding(16)
        .appCellSurface(accent: isPulsing ? .appAccent : nil, tintStrength: isPulsing ? 0.06 : 0)
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isPulsing ? Color.appAccent : .clear, lineWidth: 2)
        }
        .scaleEffect(isPulsing ? 1.015 : 1)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isPulsing)
    }

    private var priorityIndicator: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(priorityColor)
                .frame(width: 10, height: 10)
            Text(task.priority.rawValue)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.top, 4)
    }

    private var priorityColor: Color {
        switch task.priority {
        case .high: return .appPrimary
        case .medium: return .appAccent
        case .low: return .appTextSecondary
        }
    }
}

private struct FlowLayoutTags: View {
    let task: TaskItem

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                MetaTag(text: task.category.rawValue, icon: task.category.iconName, style: .neutral)
                if task.recurrence != .none {
                    MetaTag(text: task.recurrence.rawValue, icon: "repeat", style: .accent)
                }
                if let due = task.dueDate {
                    MetaTag(
                        text: dueLabel(due),
                        icon: "calendar",
                        style: task.isOverdue ? .warning : .neutral
                    )
                }
                if let minutes = task.estimatedMinutes {
                    MetaTag(text: "\(minutes)m", icon: "clock", style: .neutral)
                }
                if let progress = task.subtasksProgress {
                    MetaTag(text: progress, icon: "checklist", style: .primary)
                }
                ForEach(task.tags, id: \.self) { tag in
                    MetaTag(text: "#\(tag)", style: .accent)
                }
            }
        }
    }

    private func dueLabel(_ date: Date) -> String {
        if task.isOverdue { return "Overdue" }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }
}
