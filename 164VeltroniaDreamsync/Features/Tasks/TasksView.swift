import SwiftUI

struct TasksView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel: TasksViewModel
    @State private var scaleTaskID: UUID?
    @State private var quickAddText = ""
    @State private var editMode: EditMode = .inactive

    init(bannerManager: AchievementBannerManager) {
        _viewModel = StateObject(wrappedValue: TasksViewModel(store: .shared, bannerManager: bannerManager))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppBackgroundView()
                SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessOverlay)

                VStack(spacing: 0) {
                    AppSearchBar(text: $viewModel.searchText, placeholder: "Search tasks...")
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    smartListChips

                    if viewModel.hasActiveTasks {
                        List(selection: $viewModel.selectedIDs) {
                            ForEach(viewModel.filteredActiveTasks) { task in
                                TaskCardCell(
                                    task: task,
                                    isSelected: viewModel.selectedIDs.contains(task.id),
                                    showSelection: viewModel.isSelectionMode,
                                    isPulsing: viewModel.pulseTaskID == task.id
                                )
                                .tag(task.id)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard !viewModel.isSelectionMode else { return }
                                    FeedbackService.lightTap()
                                    viewModel.editingTask = task
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        scaleTaskID = task.id
                                        viewModel.completeTask(task)
                                    } label: {
                                        Label("Done", systemImage: "checkmark")
                                    }
                                    .tint(Color.appPrimary)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button { viewModel.editingTask = task } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(Color.appAccent)
                                    Button { viewModel.archiveTask(task) } label: {
                                        Label("Archive", systemImage: "archivebox")
                                    }
                                    .tint(Color.appTextSecondary)
                                    Button(role: .destructive) { viewModel.deleteTask(task) } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .onMove { s, d in viewModel.moveTasks(from: s, to: d) }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .environment(\.editMode, $editMode)
                    } else {
                        EmptyStateView(
                            icon: "checklist",
                            title: "No Tasks Yet",
                            message: "Tap '+' above to start creating your first task"
                        )
                        .frame(maxHeight: .infinity)
                    }
                }

                if viewModel.showUndoToast {
                    UndoToastView(message: "Task deleted") { viewModel.performUndo() }
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { tasksToolbar }
            .toolbarBackground(Color.appBackground.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom) { bottomBar }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showUndoToast)
        .sheet(isPresented: $viewModel.showAddSheet, onDismiss: { viewModel.templateDraft = nil }) {
            TaskFormSheet(initialDraft: viewModel.templateDraft) { viewModel.addTask($0); viewModel.templateDraft = nil }
        }
        .sheet(isPresented: $viewModel.showTemplatesSheet) {
            TaskTemplatesSheet { draft in viewModel.templateDraft = draft; viewModel.showAddSheet = true }
        }
        .onChange(of: viewModel.isSelectionMode) { editMode = $0 ? .active : .inactive }
        .sheet(item: $viewModel.editingTask) { TaskFormSheet(existingTask: $0) { viewModel.updateTask($0) } }
        .sheet(isPresented: $viewModel.showFilterSheet) { TaskFilterSheet().environmentObject(store) }
        .onAppear { viewModel.refresh() }
    }

    private var smartListChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TaskSmartList.allCases) { list in
                    FilterChip(title: list.rawValue, isSelected: viewModel.smartList == list) {
                        store.selectedSmartList = list.rawValue
                        FeedbackService.lightTap()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    @ToolbarContentBuilder
    private var tasksToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                NavigationLink { CompletedTasksView(tasks: viewModel.completedTasks) } label: {
                    Label("Completed", systemImage: "checkmark.circle")
                }
                NavigationLink { ArchivedTasksView() } label: {
                    Label("Archive", systemImage: "archivebox")
                }
            } label: {
                Image(systemName: "tray.full").foregroundStyle(Color.appTextSecondary)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 8) {
                Button {
                    viewModel.isSelectionMode.toggle()
                    if !viewModel.isSelectionMode { viewModel.selectedIDs.removeAll() }
                    FeedbackService.lightTap()
                } label: {
                    Image(systemName: viewModel.isSelectionMode ? "checkmark.circle.fill" : "checkmark.circle")
                        .foregroundStyle(Color.appPrimary)
                }
                Button { viewModel.showFilterSheet = true } label: {
                    Image(systemName: "slider.horizontal.3").foregroundStyle(Color.appTextSecondary)
                }
                Menu {
                    Button { viewModel.showAddSheet = true } label: { Label("New Task", systemImage: "plus") }
                    Button { viewModel.showTemplatesSheet = true } label: { Label("Templates", systemImage: "doc.on.doc") }
                } label: {
                    Image(systemName: "plus.circle.fill").foregroundStyle(Color.appPrimary).font(.title2)
                }
            }
        }
        if viewModel.isSelectionMode {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Complete") { viewModel.bulkCompleteSelected() }.foregroundStyle(Color.appPrimary)
                Spacer()
                Button("Delete", role: .destructive) { viewModel.bulkDeleteSelected() }
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill").foregroundStyle(Color.appAccent)
                    TextField("Quick add task...", text: $quickAddText)
                        .foregroundStyle(Color.appTextPrimary)
                }
                .padding(12)
                .appSurface(cornerRadius: 14, elevation: .flat)
                Button {
                    viewModel.addQuickTask(title: quickAddText)
                    quickAddText = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.appPrimary)
                }
                .disabled(quickAddText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            HStack {
                Label("\(viewModel.completedTasks.count) done", systemImage: "checkmark.seal")
                Spacer()
                Text(viewModel.smartList.rawValue).font(.caption.weight(.medium))
            }
            .font(.caption)
            .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppGradients.tabBar)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppGradients.borderHighlight, lineWidth: 1)
        }
    }
}
