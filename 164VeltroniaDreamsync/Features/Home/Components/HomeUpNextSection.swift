import SwiftUI

struct HomeUpNextSection: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var completedTaskID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(
                title: "Up Next",
                subtitle: upNextSubtitle
            )

            if store.upNextTasks.isEmpty && store.habitsDueToday.isEmpty {
                AppCard {
                    EmptyStateView(
                        icon: "checkmark.seal.fill",
                        title: "You're All Caught Up",
                        message: "No urgent tasks or habits for today. Great job!"
                    )
                }
            } else {
                if !store.upNextTasks.isEmpty {
                    AppCard {
                        VStack(spacing: 0) {
                            ForEach(Array(store.upNextTasks.enumerated()), id: \.element.id) { index, task in
                                HomeTaskRow(
                                    task: task,
                                    isCompleting: completedTaskID == task.id
                                ) {
                                    completeTask(task)
                                }
                                if index < store.upNextTasks.count - 1 {
                                    Divider().opacity(0.35)
                                }
                            }
                        }
                    }
                }

                if !store.habitsDueToday.isEmpty {
                    AppCard(accent: .appAccent) {
                        VStack(spacing: 0) {
                            ForEach(Array(store.habitsDueToday.prefix(4).enumerated()), id: \.element.id) { index, habit in
                                HomeHabitRow(habit: habit) {
                                    _ = store.toggleHabitCheckIn(id: habit.id)
                                    FeedbackService.lightTap()
                                }
                                if index < min(store.habitsDueToday.count, 4) - 1 {
                                    Divider().opacity(0.35)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var upNextSubtitle: String {
        let tasks = store.upNextTasks.count
        let habits = store.habitsDueToday.filter { !$0.completedToday }.count
        if tasks == 0 && habits == 0 { return "Nothing pending" }
        var parts: [String] = []
        if tasks > 0 { parts.append("\(tasks) tasks") }
        if habits > 0 { parts.append("\(habits) habits") }
        return parts.joined(separator: " · ")
    }

    private func completeTask(_ task: TaskItem) {
        completedTaskID = task.id
        FeedbackService.lightTap()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            store.completeTask(id: task.id)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completedTaskID = nil
        }
    }
}

private struct HomeTaskRow: View {
    let task: TaskItem
    let isCompleting: Bool
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onComplete) {
                ZStack {
                    Circle()
                        .stroke(task.isOverdue ? Color.red.opacity(0.8) : Color.appAccent, lineWidth: 2)
                        .frame(width: 26, height: 26)
                    if isCompleting {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appPrimary)
                    }
                }
            }
            .buttonStyle(LightTapButtonStyle())

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    if task.isOverdue {
                        MetaTag(text: "Overdue", icon: "exclamationmark.circle", style: .accent)
                    } else if task.isDueToday {
                        MetaTag(text: "Due today", style: .neutral)
                    }
                    if task.isFlagged {
                        Image(systemName: "flag.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }
            Spacer(minLength: 0)
            IconBadge(icon: task.category.iconName, color: .appPrimary, size: 32)
        }
        .padding(.vertical, 10)
        .opacity(isCompleting ? 0.5 : 1)
    }
}

private struct HomeHabitRow: View {
    let habit: HabitItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(habit.completedToday ? Color.appPrimary : Color.appBackground)
                        .frame(width: 28, height: 28)
                    Image(systemName: habit.completedToday ? "checkmark" : "leaf.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(habit.completedToday ? Color.appTextPrimary : Color.appAccent)
                }
            }
            .buttonStyle(LightTapButtonStyle())

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("\(habit.streak) day streak")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
            Text(habit.group.rawValue)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.appBackground))
        }
        .padding(.vertical, 10)
    }
}
