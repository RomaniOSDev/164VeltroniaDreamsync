import SwiftUI

struct UndoToastView: View {
    let message: String
    let onUndo: () -> Void

    var body: some View {
        HStack {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Button("Undo", action: onUndo)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appPrimary)
        }
        .padding(16)
        .appSurface(elevation: .high, accent: .appPrimary, tintStrength: 0.06)
        .padding(.horizontal, 16)
    }
}
