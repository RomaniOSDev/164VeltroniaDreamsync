import SwiftUI

private struct OnboardingPage: Identifiable {
    let id: Int
    let headline: String
    let description: String
    let imageName: String
    let icon: String
    let features: [String]
}

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            headline: "Your Productivity Hub",
            description: "Tasks, focus sessions, and habits — everything you need in one calm, beautiful workspace.",
            imageName: "home_hero",
            icon: "sparkles",
            features: ["Daily goals & progress", "Quick insights", "Smart shortcuts"]
        ),
        OnboardingPage(
            id: 1,
            headline: "Tasks That Work for You",
            description: "Capture ideas fast, set due dates, and clear your list with a satisfying swipe or tap.",
            imageName: "home_tasks",
            icon: "checklist",
            features: ["Categories & priorities", "Due dates & reminders", "Quick add from anywhere"]
        ),
        OnboardingPage(
            id: 2,
            headline: "Deep Focus Mode",
            description: "Run Pomodoro or deep-work sessions and link them to the task you're working on.",
            imageName: "home_focus",
            icon: "timer",
            features: ["Pomodoro & deep work", "Session history", "Task linking"]
        ),
        OnboardingPage(
            id: 3,
            headline: "Habits That Stick",
            description: "Build streaks with daily check-ins and watch your routines become second nature.",
            imageName: "home_habits",
            icon: "leaf.fill",
            features: ["Streak tracking", "Scheduled habits", "Progress journal"]
        )
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                headerBar

                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        OnboardingPageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                footerControls
            }
        }
    }

    private var headerBar: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Color.appAccent)
                Text("Step \(currentPage + 1) of \(pages.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
            if currentPage < pages.count - 1 {
                Button("Skip") {
                    FeedbackService.lightTap()
                    store.completeOnboarding()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var footerControls: some View {
        VStack(spacing: 20) {
            pageIndicator

            Button(action: advance) {
                HStack(spacing: 8) {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                    Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "checkmark")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding(.top, 8)
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(pages) { page in
                Capsule(style: .continuous)
                    .fill(page.id == currentPage ? AppGradients.accentBar : LinearGradient(
                        colors: [Color.appTextSecondary.opacity(0.35), Color.appTextSecondary.opacity(0.35)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: page.id == currentPage ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentPage)
            }
        }
    }

    private func advance() {
        FeedbackService.lightTap()
        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            FeedbackService.mediumAction()
            store.completeOnboarding()
        }
    }
}

// MARK: - Page

private struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                OnboardingHeroCard(imageName: page.imageName, icon: page.icon)
                    .scaleEffect(appeared ? 1 : 0.92)
                    .opacity(appeared ? 1 : 0)

                VStack(spacing: 12) {
                    Text(page.headline)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.center)

                    Text(page.description)
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 4)

                AppCard(accent: .appAccent) {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(page.features, id: \.self) { feature in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.appAccent, .appPrimary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                Text(feature)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color.appTextPrimary)
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
                .offset(y: appeared ? 0 : 16)
                .opacity(appeared ? 1 : 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                appeared = true
            }
        }
        .onDisappear { appeared = false }
    }
}

// MARK: - Hero card

private struct OnboardingHeroCard: View {
    let imageName: String
    let icon: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()

            LinearGradient(
                colors: [
                    Color.appBackground.opacity(0.1),
                    Color.appBackground.opacity(0.5),
                    Color.appBackground.opacity(0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack {
                IconBadge(icon: icon, color: .appAccent, size: 52)
                Spacer()
            }
            .padding(18)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppGradients.borderStroke(accent: .appAccent), lineWidth: 1)
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.28), radius: 14, y: 6)
    }
}
