import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            AppGradients.background

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.appPrimary.opacity(0.14), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: -120, y: -200)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.appAccent.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: 140, y: 320)
        }
        .ignoresSafeArea()
    }
}
