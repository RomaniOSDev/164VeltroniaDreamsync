import Foundation

enum HabitGroup: String, Codable, CaseIterable, Identifiable {
    case morning = "Morning"
    case health = "Health"
    case work = "Work"
    case other = "Other"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .health: return "heart.fill"
        case .work: return "briefcase.fill"
        case .other: return "folder.fill"
        }
    }
}
