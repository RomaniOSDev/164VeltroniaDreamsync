import Foundation

enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case learning = "Learning"
    case other = "Other"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .health: return "heart.fill"
        case .learning: return "book.fill"
        case .other: return "folder.fill"
        }
    }
}

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

struct TaskSubtask: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var completed: Bool

    init(id: UUID = UUID(), title: String, completed: Bool = false) {
        self.id = id
        self.title = title
        self.completed = completed
    }
}

struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var notes: String
    var category: TaskCategory
    var priority: TaskPriority
    var tags: [String]
    var dueDate: Date?
    var estimatedMinutes: Int?
    var isFlagged: Bool
    var subtasks: [TaskSubtask]
    var recurrence: TaskRecurrence
    var recurringWeekdays: [Int]
    var isRecurringTemplate: Bool
    var recurringParentId: UUID?
    var spawnedForDay: Date?
    var isArchived: Bool
    var completed: Bool
    var completedAt: Date?
    var sortOrder: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        category: TaskCategory = .other,
        priority: TaskPriority = .medium,
        tags: [String] = [],
        dueDate: Date? = nil,
        estimatedMinutes: Int? = nil,
        isFlagged: Bool = false,
        subtasks: [TaskSubtask] = [],
        recurrence: TaskRecurrence = .none,
        recurringWeekdays: [Int] = [],
        isRecurringTemplate: Bool = false,
        recurringParentId: UUID? = nil,
        spawnedForDay: Date? = nil,
        isArchived: Bool = false,
        completed: Bool = false,
        completedAt: Date? = nil,
        sortOrder: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.category = category
        self.priority = priority
        self.tags = tags
        self.dueDate = dueDate
        self.estimatedMinutes = estimatedMinutes
        self.isFlagged = isFlagged
        self.subtasks = subtasks
        self.recurrence = recurrence
        self.recurringWeekdays = recurringWeekdays
        self.isRecurringTemplate = isRecurringTemplate
        self.recurringParentId = recurringParentId
        self.spawnedForDay = spawnedForDay
        self.isArchived = isArchived
        self.completed = completed
        self.completedAt = completedAt
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }

    var isOverdue: Bool {
        guard let dueDate, !completed, !isArchived else { return false }
        return dueDate < Date()
    }

    var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    var subtasksProgress: String? {
        guard !subtasks.isEmpty else { return nil }
        let done = subtasks.filter(\.completed).count
        return "\(done)/\(subtasks.count)"
    }

    var tagsDisplay: String {
        tags.map { "#\($0)" }.joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case id, title, notes, category, priority, tags, dueDate, estimatedMinutes
        case isFlagged, subtasks, recurrence, recurringWeekdays, isRecurringTemplate
        case recurringParentId, spawnedForDay, isArchived, completed, completedAt
        case sortOrder, createdAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
        category = try c.decode(TaskCategory.self, forKey: .category)
        priority = try c.decode(TaskPriority.self, forKey: .priority)
        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        dueDate = try c.decodeIfPresent(Date.self, forKey: .dueDate)
        estimatedMinutes = try c.decodeIfPresent(Int.self, forKey: .estimatedMinutes)
        isFlagged = try c.decodeIfPresent(Bool.self, forKey: .isFlagged) ?? false
        subtasks = try c.decodeIfPresent([TaskSubtask].self, forKey: .subtasks) ?? []
        recurrence = try c.decodeIfPresent(TaskRecurrence.self, forKey: .recurrence) ?? .none
        recurringWeekdays = try c.decodeIfPresent([Int].self, forKey: .recurringWeekdays) ?? []
        isRecurringTemplate = try c.decodeIfPresent(Bool.self, forKey: .isRecurringTemplate) ?? false
        recurringParentId = try c.decodeIfPresent(UUID.self, forKey: .recurringParentId)
        spawnedForDay = try c.decodeIfPresent(Date.self, forKey: .spawnedForDay)
        isArchived = try c.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
        completed = try c.decode(Bool.self, forKey: .completed)
        completedAt = try c.decodeIfPresent(Date.self, forKey: .completedAt)
        sortOrder = try c.decode(Int.self, forKey: .sortOrder)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}

struct TaskDraft {
    var title: String
    var notes: String
    var category: TaskCategory
    var priority: TaskPriority
    var tagsText: String
    var hasDueDate: Bool
    var dueDate: Date
    var hasEstimate: Bool
    var estimatedMinutes: Int
    var isFlagged: Bool
    var subtasks: [TaskSubtask]
    var recurrence: TaskRecurrence
    var recurringWeekdays: Set<Int>

    var tags: [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    static var empty: TaskDraft {
        TaskDraft(
            title: "",
            notes: "",
            category: .other,
            priority: .medium,
            tagsText: "",
            hasDueDate: false,
            dueDate: Calendar.current.startOfDay(for: Date().addingTimeInterval(86400)),
            hasEstimate: false,
            estimatedMinutes: 30,
            isFlagged: false,
            subtasks: [],
            recurrence: .none,
            recurringWeekdays: []
        )
    }

    init(from task: TaskItem) {
        title = task.title
        notes = task.notes
        category = task.category
        priority = task.priority
        tagsText = task.tags.joined(separator: ", ")
        hasDueDate = task.dueDate != nil
        dueDate = task.dueDate ?? Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        hasEstimate = task.estimatedMinutes != nil
        estimatedMinutes = task.estimatedMinutes ?? 30
        isFlagged = task.isFlagged
        subtasks = task.subtasks
        recurrence = task.recurrence
        recurringWeekdays = Set(task.recurringWeekdays)
    }

    init(
        title: String,
        notes: String,
        category: TaskCategory,
        priority: TaskPriority,
        tagsText: String = "",
        hasDueDate: Bool,
        dueDate: Date,
        hasEstimate: Bool,
        estimatedMinutes: Int,
        isFlagged: Bool,
        subtasks: [TaskSubtask],
        recurrence: TaskRecurrence = .none,
        recurringWeekdays: Set<Int> = []
    ) {
        self.title = title
        self.notes = notes
        self.category = category
        self.priority = priority
        self.tagsText = tagsText
        self.hasDueDate = hasDueDate
        self.dueDate = dueDate
        self.hasEstimate = hasEstimate
        self.estimatedMinutes = estimatedMinutes
        self.isFlagged = isFlagged
        self.subtasks = subtasks
        self.recurrence = recurrence
        self.recurringWeekdays = recurringWeekdays
    }

    func buildTask(preserving existing: TaskItem? = nil) -> TaskItem {
        let isTemplate: Bool
        if let existing {
            isTemplate = existing.isRecurringTemplate
        } else {
            isTemplate = recurrence != .none
        }
        return TaskItem(
            id: existing?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            priority: priority,
            tags: tags,
            dueDate: hasDueDate ? dueDate : nil,
            estimatedMinutes: hasEstimate ? estimatedMinutes : nil,
            isFlagged: isFlagged,
            subtasks: subtasks,
            recurrence: recurrence,
            recurringWeekdays: Array(recurringWeekdays).sorted(),
            isRecurringTemplate: isTemplate,
            recurringParentId: existing?.recurringParentId,
            spawnedForDay: existing?.spawnedForDay,
            isArchived: existing?.isArchived ?? false,
            completed: existing?.completed ?? false,
            completedAt: existing?.completedAt,
            sortOrder: existing?.sortOrder ?? 0,
            createdAt: existing?.createdAt ?? Date()
        )
    }
}
