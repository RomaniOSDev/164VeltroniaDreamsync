import SwiftUI

enum FocusHabitsSegment: String, CaseIterable {
    case focus = "Focus"
    case habits = "Habits"
}

struct FocusHabitsContainerView: View {
    let bannerManager: AchievementBannerManager
    @State private var segment: FocusHabitsSegment = .focus

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 0) {
                    Picker("Section", selection: $segment) {
                        ForEach(FocusHabitsSegment.allCases, id: \.self) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                    .onChange(of: segment) { _ in
                        FeedbackService.lightTap()
                    }

                    switch segment {
                    case .focus:
                        FocusView(bannerManager: bannerManager)
                    case .habits:
                        HabitsView(bannerManager: bannerManager)
                    }
                }
            }
            .navigationTitle(segment == .focus ? "Focus" : "Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBackground.opacity(0.9), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
