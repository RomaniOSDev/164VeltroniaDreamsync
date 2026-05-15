import Foundation

enum TaskRecurrence: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"

    var id: String { rawValue }
}

enum TaskSmartList: String, CaseIterable, Identifiable {
    case all = "All"
    case dueToday = "Due Today"
    case overdue = "Overdue"
    case flagged = "Flagged"
    case noDueDate = "No Due Date"

    var id: String { rawValue }
}

struct TaskTemplate: Identifiable {
    let id: String
    let title: String
    let notes: String
    let category: TaskCategory
    let priority: TaskPriority
    let estimatedMinutes: Int?
    let tags: [String]
    let isFlagged: Bool

    static let all: [TaskTemplate] = [
        TaskTemplate(
            id: "weekly_review",
            title: "Weekly review",
            notes: "Review goals, clear inbox, plan next week.",
            category: .work,
            priority: .high,
            estimatedMinutes: 45,
            tags: ["planning"],
            isFlagged: true
        ),
        TaskTemplate(
            id: "gym",
            title: "Gym",
            notes: "Workout session — warm up, train, cool down.",
            category: .health,
            priority: .medium,
            estimatedMinutes: 60,
            tags: ["health"],
            isFlagged: false
        ),
        TaskTemplate(
            id: "email_inbox",
            title: "Email inbox",
            notes: "Process inbox to zero. Reply, delegate, or archive.",
            category: .work,
            priority: .medium,
            estimatedMinutes: 30,
            tags: ["email"],
            isFlagged: false
        )
    ]

    func makeDraft() -> TaskDraft {
        var draft = TaskDraft.empty
        draft.title = title
        draft.notes = notes
        draft.category = category
        draft.priority = priority
        draft.hasEstimate = estimatedMinutes != nil
        draft.estimatedMinutes = estimatedMinutes ?? 30
        draft.isFlagged = isFlagged
        draft.tagsText = tags.joined(separator: ", ")
        return draft
    }
}
