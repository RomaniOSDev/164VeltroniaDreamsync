import SwiftUI

struct TaskTemplatesSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (TaskDraft) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                List {
                    ForEach(TaskTemplate.all) { template in
                        Button {
                            FeedbackService.lightTap()
                            onSelect(template.makeDraft())
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(template.title)
                                    .font(.headline)
                                    .foregroundStyle(Color.appTextPrimary)
                                Text(template.notes)
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .lineLimit(2)
                                HStack {
                                    Text(template.category.rawValue)
                                    if let min = template.estimatedMinutes {
                                        Text("· \(min) min")
                                    }
                                }
                                .font(.caption2)
                                .foregroundStyle(Color.appAccent)
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.appSurface)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color.appTextSecondary)
                }
            }
            .toolbarBackground(Color.appSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
    }
}
