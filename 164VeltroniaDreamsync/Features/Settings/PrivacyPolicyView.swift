import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdownContent = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    if markdownContent.isEmpty {
                        Text("Privacy policy could not be loaded.")
                            .foregroundStyle(Color.appTextSecondary)
                            .padding()
                    } else {
                        Group {
                            if let attributed = try? AttributedString(
                                markdown: markdownContent,
                                options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
                            ) {
                                Text(attributed)
                                    .foregroundStyle(Color.appTextPrimary)
                            } else {
                                Text(markdownContent)
                                    .foregroundStyle(Color.appTextPrimary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackService.lightTap()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.appTextSecondary)
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .toolbarBackground(Color.appSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            loadPolicy()
        }
    }

    private func loadPolicy() {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            markdownContent = ""
            return
        }
        markdownContent = text
    }
}
