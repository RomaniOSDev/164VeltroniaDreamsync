import SwiftUI

struct SingleTaskModeView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTaskId: UUID?

    private var activeTasks: [TaskItem] {
        store.activeTasks
    }

    private var selectedTask: TaskItem? {
        guard let selectedTaskId else { return activeTasks.first }
        return activeTasks.first { $0.id == selectedTaskId } ?? activeTasks.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                if let task = selectedTask {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            if activeTasks.count > 1 {
                                Picker("Task", selection: Binding(
                                    get: { task.id },
                                    set: { selectedTaskId = $0 }
                                )) {
                                    ForEach(activeTasks) { item in
                                        Text(item.title).tag(item.id)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color.appPrimary)
                            }

                            Text(task.title)
                                .font(.largeTitle.bold())
                                .foregroundStyle(Color.appTextPrimary)
                                .minimumScaleFactor(0.7)

                            if !task.notes.isEmpty {
                                Text(task.notes)
                                    .font(.body)
                                    .foregroundStyle(Color.appTextSecondary)
                            }

                            if !task.tags.isEmpty {
                                Text(task.tagsDisplay)
                                    .font(.caption)
                                    .foregroundStyle(Color.appAccent)
                            }

                            if let due = task.dueDate {
                                Label(due.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                                    .foregroundStyle(task.isOverdue ? Color.red : Color.appTextSecondary)
                            }

                            if let progress = task.subtasksProgress {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Subtasks \(progress)")
                                        .font(.headline)
                                        .foregroundStyle(Color.appTextPrimary)
                                    ForEach(task.subtasks) { sub in
                                        HStack {
                                            Image(systemName: sub.completed ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(sub.completed ? Color.appPrimary : Color.appTextSecondary)
                                            Text(sub.title)
                                                .foregroundStyle(Color.appTextPrimary)
                                                .strikethrough(sub.completed)
                                        }
                                    }
                                }
                            }

                            Spacer(minLength: 40)

                            Button("Mark Complete") {
                                store.completeTask(id: task.id)
                                FeedbackService.success()
                                if activeTasks.count <= 1 {
                                    dismiss()
                                } else {
                                    selectedTaskId = nil
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .frame(maxWidth: .infinity)
                        }
                        .padding(24)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.appPrimary)
                        Text("No active tasks")
                            .foregroundStyle(Color.appTextSecondary)
                        Button("Close") { dismiss() }
                            .buttonStyle(PrimaryButtonStyle())
                    }
                }
            }
            .navigationTitle("Focus Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackService.lightTap()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.appTextSecondary)
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .toolbarBackground(Color.appBackground.opacity(0.9), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            selectedTaskId = activeTasks.first?.id
        }
    }
}
