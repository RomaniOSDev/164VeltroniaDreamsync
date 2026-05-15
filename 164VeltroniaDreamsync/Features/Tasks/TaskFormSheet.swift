import SwiftUI

struct TaskFormSheet: View {
    @Environment(\.dismiss) private var dismiss

    let existingTask: TaskItem?
    let onSave: (TaskItem) -> Void

    @State private var draft: TaskDraft
    @State private var newSubtaskTitle = ""
    @State private var shakeTrigger = 0
    @State private var errorMessage: String?

    private let estimateOptions = [15, 30, 45, 60, 90, 120, 180]
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    init(existingTask: TaskItem? = nil, initialDraft: TaskDraft? = nil, onSave: @escaping (TaskItem) -> Void) {
        self.existingTask = existingTask
        self.onSave = onSave
        if let existingTask {
            _draft = State(initialValue: TaskDraft(from: existingTask))
        } else if let initialDraft {
            _draft = State(initialValue: initialDraft)
        } else {
            _draft = State(initialValue: .empty)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                Form {
                    detailsSection
                    schedulingSection
                    recurrenceSection
                    subtasksSection
                    optionsSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existingTask == nil ? "Add Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color.appTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(Color.appPrimary)
                }
            }
            .toolbarBackground(Color.appSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.large])
    }

    private var detailsSection: some View {
        Section("Details") {
            TextField("Task title", text: $draft.title)
                .foregroundStyle(Color.appTextPrimary)
                .shake(trigger: shakeTrigger)
            if let errorMessage {
                Text(errorMessage).font(.caption).foregroundStyle(.red)
            }
            ZStack(alignment: .topLeading) {
                if draft.notes.isEmpty {
                    Text("Notes (optional)")
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.top, 8).padding(.leading, 4)
                }
                TextEditor(text: $draft.notes)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(minHeight: 80)
                    .scrollContentBackground(.hidden)
            }
            TextField("Tags (comma separated)", text: $draft.tagsText)
                .foregroundStyle(Color.appTextPrimary)
            Picker("Category", selection: $draft.category) {
                ForEach(TaskCategory.allCases) { cat in
                    Label(cat.rawValue, systemImage: cat.iconName).tag(cat)
                }
            }
            Picker("Priority", selection: $draft.priority) {
                ForEach(TaskPriority.allCases) { p in
                    Text(p.rawValue).tag(p)
                }
            }
            .pickerStyle(.segmented)
        }
        .listRowBackground(Color.appSurface)
    }

    private var schedulingSection: some View {
        Section("Schedule") {
            Toggle("Due date", isOn: $draft.hasDueDate).tint(Color.appPrimary)
            if draft.hasDueDate {
                DatePicker("Due", selection: $draft.dueDate, displayedComponents: [.date, .hourAndMinute])
            }
            Toggle("Time estimate", isOn: $draft.hasEstimate).tint(Color.appPrimary)
            if draft.hasEstimate {
                Picker("Duration", selection: $draft.estimatedMinutes) {
                    ForEach(estimateOptions, id: \.self) { m in
                        Text(estimateLabel(m)).tag(m)
                    }
                }
            }
        }
        .listRowBackground(Color.appSurface)
    }

    private var recurrenceSection: some View {
        Section("Repeat") {
            Picker("Recurrence", selection: $draft.recurrence) {
                ForEach(TaskRecurrence.allCases) { r in
                    Text(r.rawValue).tag(r)
                }
            }
            if draft.recurrence == .weekly {
                ForEach(1...7, id: \.self) { day in
                    let selected = draft.recurringWeekdays.contains(day)
                    Button {
                        if selected { draft.recurringWeekdays.remove(day) }
                        else { draft.recurringWeekdays.insert(day) }
                        FeedbackService.lightTap()
                    } label: {
                        HStack {
                            Text(weekdaySymbols[day - 1])
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            if selected {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.appPrimary)
                            }
                        }
                    }
                }
            }
        }
        .listRowBackground(Color.appSurface)
    }

    private var subtasksSection: some View {
        Section("Subtasks") {
            ForEach($draft.subtasks) { $subtask in
                HStack {
                    Toggle("", isOn: $subtask.completed).labelsHidden().tint(Color.appPrimary)
                    TextField("Subtask", text: $subtask.title).foregroundStyle(Color.appTextPrimary)
                }
            }
            .onDelete { draft.subtasks.remove(atOffsets: $0) }
            HStack {
                TextField("Add subtask", text: $newSubtaskTitle).foregroundStyle(Color.appTextPrimary)
                Button { addSubtask() } label: {
                    Image(systemName: "plus.circle.fill").foregroundStyle(Color.appPrimary)
                }
            }
        }
        .listRowBackground(Color.appSurface)
    }

    private var optionsSection: some View {
        Section("Options") {
            Toggle(isOn: $draft.isFlagged) {
                Label("Flag as important", systemImage: "flag.fill")
            }
            .tint(Color.appPrimary)
        }
        .listRowBackground(Color.appSurface)
    }

    private func estimateLabel(_ minutes: Int) -> String {
        minutes < 60 ? "\(minutes) min" : "\(minutes / 60) hr"
    }

    private func addSubtask() {
        let t = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        draft.subtasks.append(TaskSubtask(title: t))
        newSubtaskTitle = ""
        FeedbackService.lightTap()
    }

    private func save() {
        let trimmed = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a task title."
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        draft.title = trimmed
        draft.subtasks = draft.subtasks.filter { !$0.title.trimmingCharacters(in: .whitespaces).isEmpty }
        onSave(draft.buildTask(preserving: existingTask))
        dismiss()
    }
}
