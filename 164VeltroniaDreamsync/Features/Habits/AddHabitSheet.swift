import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    let habit: HabitItem?
    let onSave: (HabitItem) -> Void

    @State private var title = ""
    @State private var group: HabitGroup = .other
    @State private var useSchedule = false
    @State private var weekdays: Set<Int> = []
    @State private var shakeTrigger = 0
    @State private var errorMessage: String?

    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                Form {
                    Section {
                        TextField("Habit name", text: $title)
                            .foregroundStyle(Color.appTextPrimary)
                            .shake(trigger: shakeTrigger)
                        if let errorMessage {
                            Text(errorMessage).font(.caption).foregroundStyle(.red)
                        }
                    }
                    .listRowBackground(Color.appSurface)

                    Section("Group") {
                        Picker("Group", selection: $group) {
                            ForEach(HabitGroup.allCases) { g in
                                Label(g.rawValue, systemImage: g.iconName).tag(g)
                            }
                        }
                    }
                    .listRowBackground(Color.appSurface)

                    Section("Schedule") {
                        Toggle("Specific days only", isOn: $useSchedule).tint(Color.appPrimary)
                        if useSchedule {
                            ForEach(1...7, id: \.self) { day in
                                let selected = weekdays.contains(day)
                                Button {
                                    if selected { weekdays.remove(day) } else { weekdays.insert(day) }
                                    FeedbackService.lightTap()
                                } label: {
                                    HStack {
                                        Text(weekdaySymbols[day - 1])
                                            .foregroundStyle(Color.appTextPrimary)
                                        Spacer()
                                        if selected {
                                            Image(systemName: "checkmark").foregroundStyle(Color.appPrimary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.appSurface)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(habit == nil ? "Add Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { FeedbackService.lightTap(); dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.foregroundStyle(Color.appPrimary)
                }
            }
            .toolbarBackground(Color.appSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear { loadHabit() }
        .presentationDetents([.medium, .large])
    }

    private func loadHabit() {
        guard let habit else { return }
        title = habit.title
        group = habit.group
        useSchedule = !habit.scheduledWeekdays.isEmpty
        weekdays = Set(habit.scheduledWeekdays)
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a habit name."
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        var item = habit ?? HabitItem(title: trimmed)
        item.title = trimmed
        item.group = group
        item.scheduledWeekdays = useSchedule ? Array(weekdays).sorted() : []
        onSave(item)
        dismiss()
    }
}
