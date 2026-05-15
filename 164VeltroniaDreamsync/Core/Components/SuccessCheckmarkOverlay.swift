import SwiftUI

struct SuccessCheckmarkOverlay: View {
    @Binding var isVisible: Bool

    var body: some View {
        ZStack {
            if isVisible {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.appAccent)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
        .allowsHitTesting(false)
    }

}

enum SuccessOverlayHelper {
    static func trigger(show: @escaping (Bool) -> Void) {
        show(true)
        FeedbackService.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            show(false)
        }
    }
}
