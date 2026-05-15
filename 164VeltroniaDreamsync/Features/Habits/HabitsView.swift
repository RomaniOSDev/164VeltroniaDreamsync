import SwiftUI

struct HabitsView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel: HabitsViewModel

    init(bannerManager: AchievementBannerManager) {
        _viewModel = StateObject(wrappedValue: HabitsViewModel(store: .shared, bannerManager: bannerManager))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                AppSearchBar(text: $viewModel.searchText, placeholder: "Search habits...")
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                groupFilter

                if viewModel.hasHabits {
                    List {
                        ForEach(viewModel.habits) { habit in
                            NavigationLink {
                                HabitJournalView(habit: habit)
                            } label: {
                                HabitCardCell(
                                    habit: habit,
                                    isCompleted: store.habits.first(where: { $0.id == habit.id })?.completedToday ?? false,
                                    onToggle: { viewModel.toggleHabit(habit) },
                                    isPulsing: viewModel.pulseHabitID == habit.id,
                                    onJournal: {}
                                )
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing) {
                                Button { viewModel.editingHabit = habit } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(Color.appAccent)
                                Button(role: .destructive) { viewModel.deleteHabit(habit) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                } else {
                    EmptyStateView(
                        icon: "leaf.circle",
                        title: "Start Building Your Habits Today!",
                        message: "Tap '+ Add Habit' to create your first habit"
                    )
                    .frame(maxHeight: .infinity)
                }
            }

            Button {
                FeedbackService.lightTap()
                viewModel.showAddSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add Habit")
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Capsule(style: .continuous).fill(AppGradients.primaryButton))
                .overlay {
                    Capsule(style: .continuous).stroke(AppGradients.borderHighlight, lineWidth: 1)
                }
                .compositingGroup()
                .shadow(color: Color.appPrimary.opacity(0.35), radius: 8, y: 4)
            }
            .buttonStyle(LightTapButtonStyle())
            .padding(20)
        }
        .overlay { SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessOverlay) }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddHabitSheet(habit: nil) { viewModel.saveHabit($0) }
        }
        .sheet(item: $viewModel.editingHabit) { habit in
            AddHabitSheet(habit: habit) { viewModel.saveHabit($0) }
        }
        .onAppear { store.resetDailyHabitsIfNeeded() }
    }

    private var groupFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: viewModel.selectedGroup == nil) {
                    viewModel.selectedGroup = nil
                    FeedbackService.lightTap()
                }
                ForEach(HabitGroup.allCases) { group in
                    FilterChip(title: group.rawValue, isSelected: viewModel.selectedGroup == group) {
                        viewModel.selectedGroup = group
                        FeedbackService.lightTap()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}
