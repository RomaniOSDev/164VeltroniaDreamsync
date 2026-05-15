import Foundation

struct HabitItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var group: HabitGroup
    var scheduledWeekdays: [Int]
    var checkInDates: [Date]
    var streak: Int
    var completedToday: Bool
    var lastCheckInDate: Date?
    var totalCheckIns: Int

    init(
        id: UUID = UUID(),
        title: String,
        group: HabitGroup = .other,
        scheduledWeekdays: [Int] = [],
        checkInDates: [Date] = [],
        streak: Int = 0,
        completedToday: Bool = false,
        lastCheckInDate: Date? = nil,
        totalCheckIns: Int = 0
    ) {
        self.id = id
        self.title = title
        self.group = group
        self.scheduledWeekdays = scheduledWeekdays
        self.checkInDates = checkInDates
        self.streak = streak
        self.completedToday = completedToday
        self.lastCheckInDate = lastCheckInDate
        self.totalCheckIns = totalCheckIns
    }

    var isScheduledToday: Bool {
        if scheduledWeekdays.isEmpty { return true }
        let weekday = Calendar.current.component(.weekday, from: Date())
        return scheduledWeekdays.contains(weekday)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, group, scheduledWeekdays, checkInDates
        case streak, completedToday, lastCheckInDate, totalCheckIns
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        group = try c.decodeIfPresent(HabitGroup.self, forKey: .group) ?? .other
        scheduledWeekdays = try c.decodeIfPresent([Int].self, forKey: .scheduledWeekdays) ?? []
        checkInDates = try c.decodeIfPresent([Date].self, forKey: .checkInDates) ?? []
        streak = try c.decode(Int.self, forKey: .streak)
        completedToday = try c.decode(Bool.self, forKey: .completedToday)
        lastCheckInDate = try c.decodeIfPresent(Date.self, forKey: .lastCheckInDate)
        totalCheckIns = try c.decode(Int.self, forKey: .totalCheckIns)
    }
}
