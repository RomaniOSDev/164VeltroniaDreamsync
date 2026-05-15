import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showWeeklyReport = false
    @State private var showPeriodStats = false
    @State private var showSingleTask = false

    private let goalColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private let shortcutColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        HomeHeroBanner(
                            greeting: greetingText,
                            progress: store.overallDailyProgress,
                            tasksDone: store.tasksCompletedToday,
                            focusSessions: store.focusSessionsToday,
                            habitCheckIns: store.habitCheckInsToday
                        )

                        goalWidgetsRow

                        HomeUpNextSection()

                        insightsSection

                        shortcutsSection

                        focusSnapshotCard

                        HomeAchievementWidget()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBackground.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $showWeeklyReport) { WeeklyReportView().environmentObject(store) }
        .sheet(isPresented: $showPeriodStats) { PeriodStatsView().environmentObject(store) }
        .fullScreenCover(isPresented: $showSingleTask) { SingleTaskModeView().environmentObject(store) }
        .onAppear {
            store.processRecurringTasks()
            store.resetDailyHabitsIfNeeded()
        }
    }

    // MARK: - Goal Widgets

    private var goalWidgetsRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Today's Goals",
                subtitle: dailyGoalsSubtitle
            )
            LazyVGrid(columns: goalColumns, spacing: 10) {
                HomeGoalWidgetCard(
                    imageName: "home_tasks",
                    title: "Tasks",
                    subtitle: "Complete daily tasks",
                    current: store.tasksCompletedToday,
                    goal: store.dailyTaskGoal,
                    accent: .appPrimary
                ) { switchTab(.tasks) }

                HomeGoalWidgetCard(
                    imageName: "home_focus",
                    title: "Focus",
                    subtitle: "Finish focus sessions",
                    current: store.focusSessionsToday,
                    goal: store.dailyFocusGoal,
                    accent: .appAccent
                ) { switchTab(.focusHabits) }

                HomeGoalWidgetCard(
                    imageName: "home_habits",
                    title: "Habits",
                    subtitle: "Check in today",
                    current: store.habitCheckInsToday,
                    goal: store.dailyHabitGoal,
                    accent: .appPrimary
                ) { switchTab(.focusHabits) }
            }
        }
    }

    private var dailyGoalsSubtitle: String {
        let percent = Int(store.overallDailyProgress * 100)
        if percent >= 100 { return "All goals reached — amazing!" }
        return "\(percent)% of your daily goals complete"
    }

    // MARK: - Insights

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Insights", subtitle: "Your productivity at a glance")
            LazyVGrid(columns: shortcutColumns, spacing: 10) {
                HomeInsightWidget(
                    imageName: "home_tasks",
                    value: "\(store.activeTasks.count)",
                    label: "Active tasks",
                    icon: "checklist"
                ) { switchTab(.tasks) }

                HomeInsightWidget(
                    imageName: "home_focus",
                    value: "\(store.focusMinutesToday)m",
                    label: "Focus today",
                    icon: "timer"
                ) { switchTab(.focusHabits) }

                HomeInsightWidget(
                    imageName: "home_habits",
                    value: "\(store.streakDays)",
                    label: "Day streak",
                    icon: "flame.fill"
                )

                HomeInsightWidget(
                    imageName: "home_hero",
                    value: "\(store.achievementsUnlocked.count)",
                    label: "Achievements",
                    icon: "star.fill"
                ) { switchTab(.settings) }
            }
        }
    }

    // MARK: - Shortcuts

    private var shortcutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Shortcuts", subtitle: "Jump to key features")
            LazyVGrid(columns: shortcutColumns, spacing: 12) {
                HomeShortcutWidget(
                    imageName: "home_hero",
                    title: "Weekly Report",
                    subtitle: "See how your week went",
                    icon: "calendar"
                ) { showWeeklyReport = true }

                HomeShortcutWidget(
                    imageName: "home_focus",
                    title: "Statistics",
                    subtitle: "Charts & trends",
                    icon: "chart.bar.fill"
                ) { showPeriodStats = true }

                HomeShortcutWidget(
                    imageName: "home_tasks",
                    title: "Single Task",
                    subtitle: "Focus on one thing",
                    icon: "scope"
                ) { showSingleTask = true }

                HomeShortcutWidget(
                    imageName: "home_habits",
                    title: "Habits",
                    subtitle: "Track daily routines",
                    icon: "leaf.fill"
                ) { switchTab(.focusHabits) }
            }
        }
    }

    // MARK: - Focus Snapshot

    @ViewBuilder
    private var focusSnapshotCard: some View {
        if let session = store.recentFocusSession {
            AppCard(accent: .appAccent) {
                HStack(spacing: 14) {
                    Image("home_focus")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Last Focus Session")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary)
                        if let title = session.linkedTaskTitle {
                            Text(title)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                        } else {
                            Text("Deep work session")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        Text(session.completedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("\(session.durationMinutes)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.appPrimary)
                        Text("min")
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }

    private func switchTab(_ tab: MainTab) {
        NotificationCenter.default.post(
            name: .switchMainTab,
            object: nil,
            userInfo: ["tab": tab.rawValue]
        )
    }
}
