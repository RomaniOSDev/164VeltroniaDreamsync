import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 20) {
                        statsCard
                        dailyGoalsCard
                        legalCard
                        settingsCard
                        StatsAchievementsSection()
                        versionFooter
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBackground.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { FeedbackService.lightTap() }
            Button("Reset", role: .destructive) { store.resetAllData(); FeedbackService.warning() }
        } message: {
            Text("This will permanently delete all tasks, habits, focus sessions, and achievements.")
        }
    }

    private var statsCard: some View {
        AppCard(accent: .appPrimary) {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeaderView(title: "Your Stats", subtitle: "Lifetime totals")
                HStack(spacing: 0) {
                    statItem(value: "\(store.totalEntriesCreated)", label: "Entries", icon: "tray.full")
                    divider
                    statItem(value: "\(store.totalMinutesUsed)", label: "Minutes", icon: "timer")
                    divider
                    statItem(value: "\(store.streakDays)", label: "Streak", icon: "flame.fill")
                }
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.appTextSecondary.opacity(0.2))
            .frame(width: 1, height: 50)
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color.appAccent)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.appPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var dailyGoalsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeaderView(title: "Daily Goals", subtitle: "Customize your targets")
                goalStepper(icon: "checkmark.circle", label: "Tasks", value: $store.dailyTaskGoal, range: 1...20)
                goalStepper(icon: "timer", label: "Focus sessions", value: $store.dailyFocusGoal, range: 1...10)
                goalStepper(icon: "leaf", label: "Habit check-ins", value: $store.dailyHabitGoal, range: 1...20)
            }
        }
    }

    private func goalStepper(icon: String, label: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack {
            IconBadge(icon: icon, color: .appAccent, size: 36)
            Text(label)
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Stepper("\(value.wrappedValue)", value: value, in: range)
                .labelsHidden()
            Text("\(value.wrappedValue)")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 28)
        }
    }

    private var legalCard: some View {
        AppCard(accent: .appAccent) {
            VStack(spacing: 4) {
                SectionHeaderView(title: "Legal & Feedback", subtitle: "Rate us and review policies")
                    .padding(.bottom, 8)

                SettingsRowCell(title: "Rate Us", icon: "star.fill", iconColor: .appAccent) {
                    FeedbackService.lightTap()
                    rateApp()
                }
                Divider().background(Color.appBackground)

                SettingsRowCell(
                    title: AppExternalLink.privacyPolicy.title,
                    icon: AppExternalLink.privacyPolicy.iconName
                ) {
                    FeedbackService.lightTap()
                    openPolicy(AppExternalLink.privacyPolicy)
                }
                Divider().background(Color.appBackground)

                SettingsRowCell(
                    title: AppExternalLink.termsOfService.title,
                    icon: AppExternalLink.termsOfService.iconName
                ) {
                    FeedbackService.lightTap()
                    openPolicy(AppExternalLink.termsOfService)
                }
            }
        }
    }

    private var settingsCard: some View {
        AppCard {
            VStack(spacing: 4) {
                SectionHeaderView(title: "General")
                    .padding(.bottom, 8)

               

                SettingsRowCell(
                    title: "Reset All Data",
                    icon: "trash.fill",
                    iconColor: .red,
                    titleColor: .red
                ) {
                    FeedbackService.lightTap()
                    showResetAlert = true
                }
            }
        }
    }

    private var versionFooter: some View {
        Text("Version \(appVersion)")
            .font(.caption)
            .foregroundStyle(Color.appTextSecondary)
            .frame(maxWidth: .infinity)
    }

    private func openPolicy(_ link: AppExternalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
