import Foundation

struct FocusSessionRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var completedAt: Date
    var durationMinutes: Int
    var linkedTaskId: UUID?
    var linkedTaskTitle: String?
    var archived: Bool

    init(
        id: UUID = UUID(),
        completedAt: Date = Date(),
        durationMinutes: Int,
        linkedTaskId: UUID? = nil,
        linkedTaskTitle: String? = nil,
        archived: Bool = false
    ) {
        self.id = id
        self.completedAt = completedAt
        self.durationMinutes = durationMinutes
        self.linkedTaskId = linkedTaskId
        self.linkedTaskTitle = linkedTaskTitle
        self.archived = archived
    }

    enum CodingKeys: String, CodingKey {
        case id, completedAt, durationMinutes, linkedTaskId, linkedTaskTitle, archived
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        completedAt = try c.decode(Date.self, forKey: .completedAt)
        durationMinutes = try c.decode(Int.self, forKey: .durationMinutes)
        linkedTaskId = try c.decodeIfPresent(UUID.self, forKey: .linkedTaskId)
        linkedTaskTitle = try c.decodeIfPresent(String.self, forKey: .linkedTaskTitle)
        archived = try c.decodeIfPresent(Bool.self, forKey: .archived) ?? false
    }
}
