import SwiftUI

struct CompletedTasksView: View {
    @EnvironmentObject private var store: AppDataStore
    let tasks: [TaskItem]

    var body: some View {
        ZStack {
            AppBackgroundView()
            if tasks.isEmpty {
                EmptyStateView(
                    icon: "checkmark.seal",
                    title: "No Completed Tasks",
                    message: "Finished tasks will appear here"
                )
            } else {
                List {
                    ForEach(tasks) { task in
                        TaskCardCell(task: task)
                            .opacity(0.85)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.deleteTask(id: task.id)
                                    FeedbackService.mediumAction()
                                } label: { Label("Delete", systemImage: "trash") }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    store.uncompleteTask(id: task.id)
                                    FeedbackService.lightTap()
                                } label: {
                                    Label("Restore", systemImage: "arrow.uturn.backward")
                                }
                                .tint(Color.appAccent)
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Completed")
        .navigationBarTitleDisplayMode(.inline)
    }
}
