import SwiftUI

struct HabitJournalView: View {
    @EnvironmentObject private var store: AppDataStore
    let habit: HabitItem

    @State private var displayedMonth: Date = Date()

    private var monthDays: [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: leading)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        return days
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Button { shiftMonth(-1) } label: {
                            Image(systemName: "chevron.left").foregroundStyle(Color.appPrimary)
                        }
                        Spacer()
                        Text(displayedMonth, format: .dateTime.month(.wide).year())
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Button { shiftMonth(1) } label: {
                            Image(systemName: "chevron.right").foregroundStyle(Color.appPrimary)
                        }
                    }
                    .padding(.horizontal)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { symbol in
                            Text(symbol)
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        ForEach(Array(monthDays.enumerated()), id: \.offset) { _, day in
                            dayCell(day)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(habit.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func dayCell(_ day: Date?) -> some View {
        if let day {
            let checked = habit.checkInDates.contains { Calendar.current.isDate($0, inSameDayAs: day) }
            Text("\(Calendar.current.component(.day, from: day))")
                .font(.caption)
                .frame(maxWidth: .infinity, minHeight: 32)
                .background(checked ? Color.appPrimary : Color.appSurface)
                .foregroundStyle(checked ? Color.appTextPrimary : Color.appTextSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        } else {
            Color.clear.frame(height: 32)
        }
    }

    private func shiftMonth(_ value: Int) {
        if let new = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = new
            FeedbackService.lightTap()
        }
    }
}
