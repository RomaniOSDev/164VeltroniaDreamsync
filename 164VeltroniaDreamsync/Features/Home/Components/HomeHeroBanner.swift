import SwiftUI

struct HomeHeroBanner: View {
    let greeting: String
    let progress: Double
    let tasksDone: Int
    let focusSessions: Int
    let habitCheckIns: Int

    private var progressPercent: Int { Int(progress * 100) }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("home_hero")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            LinearGradient(
                colors: [
                    Color.appBackground.opacity(0.15),
                    Color.appBackground.opacity(0.55),
                    Color.appBackground.opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(greeting)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                    HStack(spacing: 12) {
                        miniStat("\(tasksDone)", label: "Tasks")
                        miniStat("\(focusSessions)", label: "Focus")
                        miniStat("\(habitCheckIns)", label: "Habits")
                    }
                }

                Spacer(minLength: 8)

                dayScoreRing
            }
            .padding(18)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppGradients.borderStroke(accent: .appAccent), lineWidth: 1)
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.28), radius: 12, y: 6)
    }

    private var dayScoreRing: some View {
        ZStack {
            Circle()
                .stroke(Color.appSurface.opacity(0.5), lineWidth: 8)
                .frame(width: 76, height: 76)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [.appAccent, .appPrimary, .appAccent],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 76, height: 76)
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(progressPercent)%")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("Today")
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }

    private func miniStat(_ value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
        }
    }
}
