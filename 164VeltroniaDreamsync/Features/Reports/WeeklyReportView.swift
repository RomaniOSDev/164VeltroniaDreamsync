import SwiftUI

struct WeeklyReportView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    private var report: (tasks: Int, focusMinutes: Int, habits: Int, bestStreak: Int) {
        StatisticsService.weeklyReport(store: store)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("This Week")
                            .font(.title2.bold())
                            .foregroundStyle(Color.appTextPrimary)

                        reportCard(
                            title: "Tasks Completed",
                            value: "\(report.tasks)",
                            icon: "checkmark.circle.fill"
                        )
                        reportCard(
                            title: "Focus Minutes",
                            value: "\(report.focusMinutes)",
                            icon: "timer"
                        )
                        reportCard(
                            title: "Habit Check-ins",
                            value: "\(report.habits)",
                            icon: "leaf.fill"
                        )
                        reportCard(
                            title: "Best Habit Streak",
                            value: "\(report.bestStreak) days",
                            icon: "flame.fill"
                        )

                        Text("Keep building momentum — small daily actions compound over time.")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    }
                    .padding(16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackService.lightTap()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .toolbarBackground(Color.appSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func reportCard(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(Color.appAccent)
                .frame(width: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
