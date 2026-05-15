import SwiftUI

struct AchievementBannerView: View {
    let payload: AchievementBannerPayload

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .foregroundStyle(
                    LinearGradient(colors: [.appAccent, .appPrimary], startPoint: .top, endPoint: .bottom)
                )
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                Text(payload.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .appSurface(elevation: .high, accent: .appAccent, tintStrength: 0.1)
        .padding(.horizontal, 16)
    }
}
