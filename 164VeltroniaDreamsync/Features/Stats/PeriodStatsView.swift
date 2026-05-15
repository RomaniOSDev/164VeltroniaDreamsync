import Charts
import SwiftUI

struct PeriodStatsView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var period: StatsPeriod = .week

    private var data: [DayStatPoint] {
        StatisticsService.chartData(store: store, period: period)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Picker("Period", selection: $period) {
                            ForEach(StatsPeriod.allCases) { p in
                                Text(p.rawValue).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)

                        chartCard(
                            title: "Tasks Completed",
                            color: .appPrimary,
                            value: \.tasksCompleted
                        )
                        chartCard(
                            title: "Focus Minutes",
                            color: .appAccent,
                            value: \.focusMinutes
                        )
                        chartCard(
                            title: "Habit Check-ins",
                            color: .appTextSecondary,
                            value: \.habitCheckIns
                        )
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Statistics")
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

    private func chartCard(
        title: String,
        color: Color,
        value: KeyPath<DayStatPoint, Int>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Chart(data) { point in
                BarMark(
                    x: .value("Day", point.date, unit: .day),
                    y: .value("Count", point[keyPath: value])
                )
                .foregroundStyle(color)
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine().foregroundStyle(Color.appTextSecondary.opacity(0.2))
                    AxisValueLabel(format: .dateTime.day())
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Color.appTextSecondary.opacity(0.2))
                    AxisValueLabel()
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
