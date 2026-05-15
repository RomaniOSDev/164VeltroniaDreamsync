import Combine
import Foundation

@MainActor
final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let tasks = "tasks"
        static let selectedCategoryFilter = "selectedCategoryFilter"
        static let isAscendingSort = "isAscendingSort"
        static let sortByDueDate = "sortByDueDate"
        static let showFlaggedOnly = "showFlaggedOnly"
        static let tasksCompleted = "tasksCompleted"
        static let focusSessionsCompleted = "focusSessionsCompleted"
        static let habitCheckIns = "habitCheckIns"
        static let uniqueHabitsCheckedIn = "uniqueHabitsCheckedIn"
        static let longestStreak = "longestStreak"
        static let focusDurationMin = "focusDurationMin"
        static let breakDurationMin = "breakDurationMin"
        static let pastSessions = "pastSessions"
        static let habits = "habits"
        static let habitReminderTime = "habitReminderTime"
        static let selectedSmartList = "selectedSmartList"
        static let dailyTaskGoal = "dailyTaskGoal"
        static let dailyFocusGoal = "dailyFocusGoal"
        static let dailyHabitGoal = "dailyHabitGoal"
        static let selectedTimerPresetId = "selectedTimerPresetId"
        static let focusLinkedTaskId = "focusLinkedTaskId"
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let lastActivityDate {
                defaults.set(lastActivityDate.timeIntervalSince1970, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveDictionary(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }

    @Published var tasks: [TaskItem] {
        didSet { save(tasks, key: Keys.tasks) }
    }

    @Published var selectedCategoryFilter: String {
        didSet { defaults.set(selectedCategoryFilter, forKey: Keys.selectedCategoryFilter) }
    }

    @Published var isAscendingSort: Bool {
        didSet { defaults.set(isAscendingSort, forKey: Keys.isAscendingSort) }
    }

    @Published var sortByDueDate: Bool {
        didSet { defaults.set(sortByDueDate, forKey: Keys.sortByDueDate) }
    }

    @Published var showFlaggedOnly: Bool {
        didSet { defaults.set(showFlaggedOnly, forKey: Keys.showFlaggedOnly) }
    }

    @Published var tasksCompleted: Int {
        didSet { defaults.set(tasksCompleted, forKey: Keys.tasksCompleted) }
    }

    @Published var focusSessionsCompleted: Int {
        didSet { defaults.set(focusSessionsCompleted, forKey: Keys.focusSessionsCompleted) }
    }

    @Published var habitCheckIns: Int {
        didSet { defaults.set(habitCheckIns, forKey: Keys.habitCheckIns) }
    }

    @Published var uniqueHabitsCheckedIn: Set<String> {
        didSet { defaults.set(Array(uniqueHabitsCheckedIn), forKey: Keys.uniqueHabitsCheckedIn) }
    }

    @Published var longestStreak: Int {
        didSet { defaults.set(longestStreak, forKey: Keys.longestStreak) }
    }

    @Published var focusDurationMin: Int {
        didSet { defaults.set(focusDurationMin, forKey: Keys.focusDurationMin) }
    }

    @Published var breakDurationMin: Int {
        didSet { defaults.set(breakDurationMin, forKey: Keys.breakDurationMin) }
    }

    @Published var pastSessions: [FocusSessionRecord] {
        didSet { save(pastSessions, key: Keys.pastSessions) }
    }

    @Published var habits: [HabitItem] {
        didSet {
            save(habits, key: Keys.habits)
            updateLongestStreak()
        }
    }

    @Published var habitReminderTime: Date {
        didSet { defaults.set(habitReminderTime.timeIntervalSince1970, forKey: Keys.habitReminderTime) }
    }

    @Published var selectedSmartList: String {
        didSet { defaults.set(selectedSmartList, forKey: Keys.selectedSmartList) }
    }

    @Published var dailyTaskGoal: Int {
        didSet { defaults.set(dailyTaskGoal, forKey: Keys.dailyTaskGoal) }
    }

    @Published var dailyFocusGoal: Int {
        didSet { defaults.set(dailyFocusGoal, forKey: Keys.dailyFocusGoal) }
    }

    @Published var dailyHabitGoal: Int {
        didSet { defaults.set(dailyHabitGoal, forKey: Keys.dailyHabitGoal) }
    }

    @Published var selectedTimerPresetId: String {
        didSet { defaults.set(selectedTimerPresetId, forKey: Keys.selectedTimerPresetId) }
    }

    @Published var focusLinkedTaskId: UUID? {
        didSet {
            if let focusLinkedTaskId {
                defaults.set(focusLinkedTaskId.uuidString, forKey: Keys.focusLinkedTaskId)
            } else {
                defaults.removeObject(forKey: Keys.focusLinkedTaskId)
            }
        }
    }

    var totalEntriesCreated: Int {
        tasks.count + habits.count + pastSessions.filter { !$0.archived }.count
    }

    var focusSessionsCompletedCount: Int { focusSessionsCompleted }
    var totalFocusMinutes: Int { totalMinutesUsed }

    private init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        if let interval = defaults.object(forKey: Keys.lastActivityDate) as? TimeInterval {
            lastActivityDate = Date(timeIntervalSince1970: interval)
        } else {
            lastActivityDate = nil
        }
        achievementsUnlocked = Self.loadDictionary(key: Keys.achievementsUnlocked)
        tasks = Self.loadArray(key: Keys.tasks) ?? []
        selectedCategoryFilter = defaults.string(forKey: Keys.selectedCategoryFilter) ?? "All"
        isAscendingSort = defaults.object(forKey: Keys.isAscendingSort) as? Bool ?? true
        sortByDueDate = defaults.bool(forKey: Keys.sortByDueDate)
        showFlaggedOnly = defaults.bool(forKey: Keys.showFlaggedOnly)
        tasksCompleted = defaults.integer(forKey: Keys.tasksCompleted)
        focusSessionsCompleted = defaults.integer(forKey: Keys.focusSessionsCompleted)
        habitCheckIns = defaults.integer(forKey: Keys.habitCheckIns)
        let habitIDs = defaults.stringArray(forKey: Keys.uniqueHabitsCheckedIn) ?? []
        uniqueHabitsCheckedIn = Set(habitIDs)
        longestStreak = defaults.integer(forKey: Keys.longestStreak)
        let focusDuration = defaults.integer(forKey: Keys.focusDurationMin)
        focusDurationMin = focusDuration == 0 ? 25 : focusDuration
        let breakDuration = defaults.integer(forKey: Keys.breakDurationMin)
        breakDurationMin = breakDuration == 0 ? 5 : breakDuration
        pastSessions = Self.loadArray(key: Keys.pastSessions) ?? []
        habits = Self.loadArray(key: Keys.habits) ?? []
        if let reminderInterval = defaults.object(forKey: Keys.habitReminderTime) as? TimeInterval {
            habitReminderTime = Date(timeIntervalSince1970: reminderInterval)
        } else {
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            habitReminderTime = Calendar.current.date(from: components) ?? Date()
        }
        selectedSmartList = defaults.string(forKey: Keys.selectedSmartList) ?? TaskSmartList.all.rawValue
        let taskGoal = defaults.integer(forKey: Keys.dailyTaskGoal)
        dailyTaskGoal = taskGoal == 0 ? 3 : taskGoal
        let focusGoal = defaults.integer(forKey: Keys.dailyFocusGoal)
        dailyFocusGoal = focusGoal == 0 ? 2 : focusGoal
        let habitGoal = defaults.integer(forKey: Keys.dailyHabitGoal)
        dailyHabitGoal = habitGoal == 0 ? 5 : habitGoal
        selectedTimerPresetId = defaults.string(forKey: Keys.selectedTimerPresetId) ?? "pomodoro"
        if let taskIdString = defaults.string(forKey: Keys.focusLinkedTaskId),
           let taskId = UUID(uuidString: taskIdString) {
            focusLinkedTaskId = taskId
        } else {
            focusLinkedTaskId = nil
        }

        processRecurringTasks()

        NotificationCenter.default.addObserver(
            forName: .dataReset,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.reloadFromDefaults()
            }
        }
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
    }

    func recordMeaningfulActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if dayDiff == 1 {
                streakDays += 1
            } else if dayDiff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastActivityDate = Date()
    }

    func addTask(_ task: TaskItem) {
        var newTask = task
        if newTask.recurrence != .none {
            newTask.isRecurringTemplate = true
        }
        newTask.sortOrder = (tasks.map(\.sortOrder).max() ?? -1) + 1
        tasks.append(newTask)
        processRecurringTasks()
        recordMeaningfulActivity()
    }

    func updateTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        let sortOrder = tasks[index].sortOrder
        var updated = task
        updated.sortOrder = sortOrder
        tasks[index] = updated
        recordMeaningfulActivity()
    }

    func completeTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }), !tasks[index].completed else { return }
        tasks[index].completed = true
        tasks[index].completedAt = Date()
        tasksCompleted += 1
        recordMeaningfulActivity()
    }

    func uncompleteTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }), tasks[index].completed else { return }
        tasks[index].completed = false
        tasks[index].completedAt = nil
        tasksCompleted = max(0, tasksCompleted - 1)
    }

    func deleteTask(id: UUID) {
        if let task = tasks.first(where: { $0.id == id }), task.completed {
            tasksCompleted = max(0, tasksCompleted - 1)
        }
        tasks.removeAll { $0.id == id }
    }

    func moveTasks(from source: IndexSet, to destination: Int, in filtered: [TaskItem]) {
        var active = tasks.filter { !$0.completed }
        var ordered = filtered
        for index in source.sorted(by: >) {
            guard index < ordered.count else { continue }
            let element = ordered.remove(at: index)
            let target = index < destination ? destination - 1 : destination
            ordered.insert(element, at: min(max(target, 0), ordered.count))
        }
        for (index, item) in ordered.enumerated() {
            if let taskIndex = active.firstIndex(where: { $0.id == item.id }) {
                active[taskIndex].sortOrder = index
            }
        }
        let completed = tasks.filter(\.completed)
        tasks = active + completed
    }

    func completeFocusSession(durationMinutes: Int) {
        let linked = linkedFocusTask
        let record = FocusSessionRecord(
            durationMinutes: durationMinutes,
            linkedTaskId: linked?.id,
            linkedTaskTitle: linked?.title
        )
        pastSessions.insert(record, at: 0)
        focusSessionsCompleted += 1
        totalSessionsCompleted += 1
        totalMinutesUsed += durationMinutes
        recordMeaningfulActivity()
    }

    func archiveSession(id: UUID) {
        guard let index = pastSessions.firstIndex(where: { $0.id == id }) else { return }
        pastSessions[index].archived = true
    }

    func toggleHabitCheckIn(id: UUID) -> Bool {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if habits[index].completedToday {
            habits[index].completedToday = false
            if habits[index].totalCheckIns > 0 {
                habits[index].totalCheckIns -= 1
                habitCheckIns = max(0, habitCheckIns - 1)
            }
            return false
        }

        if let last = habits[index].lastCheckInDate {
            let lastDay = calendar.startOfDay(for: last)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                habits[index].streak += 1
            } else if diff > 1 {
                habits[index].streak = 1
            }
        } else {
            habits[index].streak = 1
        }

        habits[index].completedToday = true
        habits[index].lastCheckInDate = Date()
        habits[index].totalCheckIns += 1
        let dayStart = today
        if !habits[index].checkInDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: dayStart) }) {
            habits[index].checkInDates.append(dayStart)
        }
        habitCheckIns += 1
        uniqueHabitsCheckedIn.insert(id.uuidString)
        updateLongestStreak()
        recordMeaningfulActivity()
        return true
    }

    func addHabit(title: String) {
        addHabit(title: title, group: .other, scheduledWeekdays: [])
    }

    func deleteHabit(id: UUID) {
        habits.removeAll { $0.id == id }
        uniqueHabitsCheckedIn.remove(id.uuidString)
    }

    func resetDailyHabitsIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var changed = false
        for index in habits.indices {
            if let last = habits[index].lastCheckInDate {
                let lastDay = calendar.startOfDay(for: last)
                if lastDay < today, habits[index].completedToday {
                    habits[index].completedToday = false
                    changed = true
                }
            }
        }
        if changed {
            habits = habits
        }
    }

    func isAchievementUnlocked(_ id: String) -> Bool {
        achievementsUnlocked[id] != nil
    }

    func unlockAchievement(id: String) -> Bool {
        guard achievementsUnlocked[id] == nil else { return false }
        achievementsUnlocked[id] = Date()
        return true
    }

    func evaluateAchievements() -> [AchievementDefinition] {
        var newlyUnlocked: [AchievementDefinition] = []
        let conditions: [(String, Bool)] = [
            ("first_task", tasksCompleted >= 1),
            ("focus_pro", focusSessionsCompleted >= 10),
            ("habit_newbie", habitCheckIns >= 1),
            ("consistent_checker", longestStreak >= 3),
            ("productivity_guru", tasksCompleted >= 100),
            ("session_expert", totalMinutesUsed >= 500),
            ("habit_devotee", uniqueHabitsCheckedIn.count >= 3),
            ("routine_master", longestStreak >= 7),
            ("week_streak", streakDays >= 7),
            ("first_focus_week", StatisticsService.focusSessionsThisWeek(store: self) >= 7),
            ("habits_fifty", habitCheckIns >= 50)
        ]
        for (achievementID, met) in conditions where met {
            if unlockAchievement(id: achievementID),
               let definition = AchievementDefinition.all.first(where: { $0.id == achievementID }) {
                newlyUnlocked.append(definition)
            }
        }
        return newlyUnlocked
    }

    func resetAllData() {
        if let domain = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: domain)
        }
        defaults.synchronize()
        applyDefaultValues()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    private func reloadFromDefaults() {
        applyDefaultValues()
    }

    private func applyDefaultValues() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        if let interval = defaults.object(forKey: Keys.lastActivityDate) as? TimeInterval {
            lastActivityDate = Date(timeIntervalSince1970: interval)
        } else {
            lastActivityDate = nil
        }
        achievementsUnlocked = Self.loadDictionary(key: Keys.achievementsUnlocked)
        tasks = Self.loadArray(key: Keys.tasks) ?? []
        selectedCategoryFilter = defaults.string(forKey: Keys.selectedCategoryFilter) ?? "All"
        isAscendingSort = defaults.object(forKey: Keys.isAscendingSort) as? Bool ?? true
        sortByDueDate = defaults.bool(forKey: Keys.sortByDueDate)
        showFlaggedOnly = defaults.bool(forKey: Keys.showFlaggedOnly)
        tasksCompleted = defaults.integer(forKey: Keys.tasksCompleted)
        focusSessionsCompleted = defaults.integer(forKey: Keys.focusSessionsCompleted)
        habitCheckIns = defaults.integer(forKey: Keys.habitCheckIns)
        uniqueHabitsCheckedIn = Set(defaults.stringArray(forKey: Keys.uniqueHabitsCheckedIn) ?? [])
        longestStreak = defaults.integer(forKey: Keys.longestStreak)
        let focusDuration = defaults.integer(forKey: Keys.focusDurationMin)
        focusDurationMin = focusDuration == 0 ? 25 : focusDuration
        let breakDuration = defaults.integer(forKey: Keys.breakDurationMin)
        breakDurationMin = breakDuration == 0 ? 5 : breakDuration
        pastSessions = Self.loadArray(key: Keys.pastSessions) ?? []
        habits = Self.loadArray(key: Keys.habits) ?? []
        if let reminderInterval = defaults.object(forKey: Keys.habitReminderTime) as? TimeInterval {
            habitReminderTime = Date(timeIntervalSince1970: reminderInterval)
        } else {
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            habitReminderTime = Calendar.current.date(from: components) ?? Date()
        }
        selectedSmartList = defaults.string(forKey: Keys.selectedSmartList) ?? TaskSmartList.all.rawValue
        let taskGoal = defaults.integer(forKey: Keys.dailyTaskGoal)
        dailyTaskGoal = taskGoal == 0 ? 3 : taskGoal
        let focusGoal = defaults.integer(forKey: Keys.dailyFocusGoal)
        dailyFocusGoal = focusGoal == 0 ? 2 : focusGoal
        let habitGoal = defaults.integer(forKey: Keys.dailyHabitGoal)
        dailyHabitGoal = habitGoal == 0 ? 5 : habitGoal
        selectedTimerPresetId = defaults.string(forKey: Keys.selectedTimerPresetId) ?? "pomodoro"
        if let taskIdString = defaults.string(forKey: Keys.focusLinkedTaskId),
           let taskId = UUID(uuidString: taskIdString) {
            focusLinkedTaskId = taskId
        } else {
            focusLinkedTaskId = nil
        }
    }

    private func updateLongestStreak() {
        let maxStreak = habits.map(\.streak).max() ?? 0
        if maxStreak > longestStreak {
            longestStreak = maxStreak
        }
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func saveDictionary(_ dict: [String: Date], key: String) {
        let stringDict = dict.mapValues { $0.timeIntervalSince1970 }
        guard let data = try? encoder.encode(stringDict) else { return }
        defaults.set(data, forKey: key)
    }

    private static func loadArray<T: Decodable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private static func loadDictionary(key: String) -> [String: Date] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let raw = try? JSONDecoder().decode([String: TimeInterval].self, from: data) else {
            return [:]
        }
        return raw.mapValues { Date(timeIntervalSince1970: $0) }
    }
}
