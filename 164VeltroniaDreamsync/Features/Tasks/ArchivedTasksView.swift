import SwiftUI

struct ArchivedTasksView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        ZStack {
            AppBackgroundView()
            if store.archivedTasks.isEmpty {
                EmptyStateView(
                    icon: "archivebox",
                    title: "Archive is Empty",
                    message: "Archived tasks will be stored here"
                )
            } else {
                List {
                    ForEach(store.archivedTasks) { task in
                        TaskCardCell(task: task)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .leading) {
                                Button {
                                    store.unarchiveTask(id: task.id)
                                    FeedbackService.lightTap()
                                } label: {
                                    Label("Restore", systemImage: "arrow.uturn.backward")
                                }
                                .tint(Color.appAccent)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.deleteTask(id: task.id)
                                    FeedbackService.mediumAction()
                                } label: { Label("Delete", systemImage: "trash") }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Archive")
        .navigationBarTitleDisplayMode(.inline)
    }
}
