import SwiftUI

struct TaskFilterSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    private var categories: [String] {
        ["All"] + TaskCategory.allCases.map(\.rawValue)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                Form {
                    Section("Smart List") {
                        Picker("List", selection: $store.selectedSmartList) {
                            ForEach(TaskSmartList.allCases) { list in
                                Text(list.rawValue).tag(list.rawValue)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                    .listRowBackground(Color.appSurface)

                    Section("Category") {
                        Picker("Filter", selection: $store.selectedCategoryFilter) {
                            ForEach(categories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                    .listRowBackground(Color.appSurface)

                    Section("Display") {
                        Toggle("Flagged only", isOn: $store.showFlaggedOnly).tint(Color.appPrimary)
                    }
                    .listRowBackground(Color.appSurface)

                    Section("Sort") {
                        Toggle("Sort by due date", isOn: $store.sortByDueDate).tint(Color.appPrimary)
                        Toggle("Ascending order", isOn: $store.isAscendingSort).tint(Color.appPrimary)
                    }
                    .listRowBackground(Color.appSurface)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
            .toolbarBackground(Color.appSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
    }
}
