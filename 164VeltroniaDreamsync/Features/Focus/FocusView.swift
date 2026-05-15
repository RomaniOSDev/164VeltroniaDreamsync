import SwiftUI

struct FocusView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: FocusViewModel
    @State private var showTaskPicker = false

    init(bannerManager: AchievementBannerManager) {
        _viewModel = StateObject(wrappedValue: FocusViewModel(store: .shared, bannerManager: bannerManager))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                heroSection
                todayStatsRow
                mainControls
                presetsSection
                linkedTaskSection
                sessionsSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .overlay { SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessOverlay) }
        .sheet(isPresented: $viewModel.showSettings) {
            FocusSettingsSheet { viewModel.applySettings() }.environmentObject(store)
        }
        .onChange(of: scenePhase) { viewModel.handleScenePhase($0) }
    }

    // MARK: - Hero Timer

    private var heroSection: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let seconds = viewModel.displayRemainingSeconds(at: context.date)
            let progress = viewModel.totalPhaseSeconds > 0
                ? 1 - Double(seconds) / Double(viewModel.totalPhaseSeconds) : 0

            FocusTimerHero(
                seconds: seconds,
                progress: progress,
                phase: viewModel.phase,
                isRunning: viewModel.isRunning,
                totalSeconds: viewModel.totalPhaseSeconds,
                formattedTime: viewModel.formattedTime(seconds),
                scale: viewModel.timerScale
            )
            .onChange(of: context.date) { viewModel.syncTick(now: $0) }
        }
    }

    private var todayStatsRow: some View {
        HStack(spacing: 10) {
            focusStatPill(
                icon: "flame.fill",
                value: "\(store.focusSessionsToday)",
                label: "Today"
            )
            focusStatPill(
                icon: "clock.fill",
                value: "\(todayFocusMinutes)",
                label: "Minutes"
            )
            focusStatPill(
                icon: "target",
                value: "\(store.dailyFocusGoal)",
                label: "Goal"
            )
        }
    }

    private var todayFocusMinutes: Int {
        store.pastSessions
            .filter { !$0.archived && Calendar.current.isDateInToday($0.completedAt) }
            .reduce(0) { $0 + $1.durationMinutes }
    }

    private func focusStatPill(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color.appAccent)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .appSurface(cornerRadius: 14, elevation: .flat, accent: .appAccent, tintStrength: 0.04)
    }

    // MARK: - Controls

    private var mainControls: some View {
        HStack(spacing: 20) {
            secondaryCircleButton(icon: "link", isActive: store.focusLinkedTaskId != nil) {
                showTaskPicker.toggle()
                FeedbackService.lightTap()
            }

            Button { viewModel.toggleTimer() } label: {
                ZStack {
                    Circle()
                        .fill(AppGradients.primaryButton)
                        .frame(width: 80, height: 80)
                        .overlay {
                            Circle().stroke(AppGradients.borderHighlight, lineWidth: 1)
                        }
                    Image(systemName: mainControlIcon)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .offset(x: viewModel.phase == .idle || !viewModel.isRunning ? 2 : 0)
                }
            }
            .compositingGroup()
            .shadow(color: Color.appPrimary.opacity(0.4), radius: 10, y: 5)
            .buttonStyle(LightTapButtonStyle())

            secondaryCircleButton(icon: "gearshape.fill", isActive: false) {
                viewModel.showSettings = true
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var mainControlIcon: String {
        if viewModel.phase == .idle { return "play.fill" }
        return viewModel.isRunning ? "pause.fill" : "play.fill"
    }

    private func secondaryCircleButton(icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        isActive
                            ? AnyShapeStyle(AppGradients.surfaceTinted(accent: .appPrimary, strength: 0.14))
                            : AnyShapeStyle(AppGradients.surface)
                    )
                    .frame(width: 52, height: 52)
                    .overlay {
                        Circle()
                            .stroke(
                                isActive ? Color.appPrimary.opacity(0.5) : Color.appTextPrimary.opacity(0.08),
                                lineWidth: 1.5
                            )
                    }
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isActive ? Color.appPrimary : Color.appTextSecondary)
            }
        }
        .buttonStyle(LightTapButtonStyle())
    }

    // MARK: - Presets

    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Timer Mode", subtitle: "Choose your focus rhythm")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TimerPreset.all.filter { $0.id != "custom" }) { preset in
                        FocusPresetCard(
                            preset: preset,
                            isSelected: store.selectedTimerPresetId == preset.id
                        ) {
                            store.applyTimerPreset(preset)
                            viewModel.applySettings()
                            FeedbackService.lightTap()
                        }
                    }
                    FocusPresetCard(
                        preset: TimerPreset(
                            id: "custom",
                            name: "Custom",
                            focusMinutes: store.focusDurationMin,
                            breakMinutes: store.breakDurationMin
                        ),
                        isSelected: store.selectedTimerPresetId == "custom"
                    ) {
                        viewModel.showSettings = true
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Linked Task

    private var linkedTaskSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { showTaskPicker.toggle() }
                FeedbackService.lightTap()
            } label: {
                HStack {
                    IconBadge(icon: "link", color: .appAccent, size: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Linked Task")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                        Text(linkedTaskSubtitle)
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: showTaskPicker ? "chevron.up" : "chevron.down")
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(14)
                .appSurface(cornerRadius: 16, elevation: .flat, accent: .appAccent, tintStrength: 0.04)
            }
            .buttonStyle(LightTapButtonStyle())

            if showTaskPicker {
                taskPickerContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var linkedTaskSubtitle: String {
        if let task = store.linkedFocusTask {
            return task.title
        }
        return "Optional — link a task to this session"
    }

    @ViewBuilder
    private var taskPickerContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                taskChip(title: "None", isSelected: store.focusLinkedTaskId == nil) {
                    store.focusLinkedTaskId = nil
                }
                ForEach(store.activeTasks) { task in
                    taskChip(title: task.title, isSelected: store.focusLinkedTaskId == task.id) {
                        store.focusLinkedTaskId = task.id
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func taskChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
            FeedbackService.lightTap()
        }) {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .foregroundStyle(isSelected ? Color.appTextPrimary : Color.appTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    if isSelected {
                        Capsule(style: .continuous).fill(AppGradients.primaryButton)
                    } else {
                        Capsule(style: .continuous).fill(AppGradients.surface)
                    }
                }
                .overlay {
                    if !isSelected {
                        Capsule(style: .continuous)
                            .stroke(Color.appTextPrimary.opacity(0.08), lineWidth: 1)
                    }
                }
        }
        .buttonStyle(LightTapButtonStyle())
    }

    // MARK: - Sessions

    @ViewBuilder
    private var sessionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeaderView(
                    title: "Recent Sessions",
                    subtitle: "\(viewModel.visibleSessions.count) recorded"
                )
                Spacer()
            }

            if viewModel.visibleSessions.isEmpty {
                AppCard {
                    EmptyStateView(
                        icon: "hourglass.circle",
                        title: "No Sessions Yet",
                        message: "Press play above to begin your first focus session"
                    )
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.visibleSessions.enumerated()), id: \.element.id) { index, session in
                        FocusSessionCardCell(
                            session: session,
                            isFirst: index == 0,
                            isLast: index == viewModel.visibleSessions.count - 1
                        )
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.archiveSession(session)
                            } label: {
                                Label("Archive", systemImage: "archivebox")
                            }
                        }
                    }
                }
            }
        }
    }
}
