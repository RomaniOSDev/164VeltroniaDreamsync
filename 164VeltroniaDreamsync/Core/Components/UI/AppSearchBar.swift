import SwiftUI

struct AppSearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.appAccent)
            TextField(placeholder, text: $text)
                .foregroundStyle(Color.appTextPrimary)
            if !text.isEmpty {
                Button {
                    text = ""
                    FeedbackService.lightTap()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .appSurface(cornerRadius: 14, elevation: .flat)
    }
}
