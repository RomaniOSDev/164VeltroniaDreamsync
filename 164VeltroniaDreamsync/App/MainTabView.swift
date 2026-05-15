import SwiftUI

enum MainTab: Int, CaseIterable {
    case home = 0
    case tasks = 1
    case focusHabits = 2
    case settings = 3

    var title: String {
        switch self {
        case .home: return "Home"
        case .tasks: return "Tasks"
        case .focusHabits: return "Focus"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "checklist"
        case .focusHabits: return "timer"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var bannerManager = AchievementBannerManager()
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack(alignment: .top) {
            AppBackgroundView()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .tasks:
                        TasksView(bannerManager: bannerManager)
                    case .focusHabits:
                        FocusHabitsContainerView(bannerManager: bannerManager)
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                customTabBar
            }

            if let banner = bannerManager.currentBanner {
                AchievementBannerView(payload: banner)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: bannerManager.currentBanner)
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            selectedTab = .home
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchMainTab)) { note in
            if let raw = note.userInfo?["tab"] as? Int, let tab = MainTab(rawValue: raw) {
                selectedTab = tab
            }
        }
        .preferredColorScheme(.dark)
    }

    private var customTabBar: some View {
        HStack(spacing: 6) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                Button { selectedTab = tab } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                        Text(tab.title)
                            .font(.caption2.weight(selectedTab == tab ? .bold : .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    .foregroundStyle(selectedTab == tab ? Color.appTextPrimary : Color.appTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppGradients.primaryButton)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(AppGradients.borderHighlight, lineWidth: 1)
                                }
                        }
                    }
                }
                .buttonStyle(LightTapButtonStyle())
                .frame(minHeight: 48)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppGradients.tabBar)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppGradients.borderHighlight, lineWidth: 1)
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.28), radius: 12, y: -3)
        .padding(.horizontal, 8)
    }
}
