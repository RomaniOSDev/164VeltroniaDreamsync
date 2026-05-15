import SwiftUI

struct FocusSettingsSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    let onApply: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                Form {
                    Section("Presets") {
                        ForEach(TimerPreset.all.filter { $0.id != "custom" }) { preset in
                            Button {
                                store.applyTimerPreset(preset)
                                FeedbackService.lightTap()
                            } label: {
                                HStack {
                                    Text(preset.name)
                                        .foregroundStyle(Color.appTextPrimary)
                                    Spacer()
                                    Text("\(preset.focusMinutes)/\(preset.breakMinutes) min")
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                    if store.selectedTimerPresetId == preset.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.appPrimary)
                                    }
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.appSurface)

                    Section("Custom Duration") {
                        Stepper("Focus: \(store.focusDurationMin) min", value: $store.focusDurationMin, in: 5...90, step: 5)
                        Stepper("Break: \(store.breakDurationMin) min", value: $store.breakDurationMin, in: 1...30, step: 1)
                    }
                    .listRowBackground(Color.appSurface)
                    .onChange(of: store.focusDurationMin) { _ in
                        store.selectedTimerPresetId = "custom"
                    }
                    .onChange(of: store.breakDurationMin) { _ in
                        store.selectedTimerPresetId = "custom"
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Timer Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        FeedbackService.lightTap()
                        onApply()
                        dismiss()
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
            .toolbarBackground(Color.appSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
    }
}
