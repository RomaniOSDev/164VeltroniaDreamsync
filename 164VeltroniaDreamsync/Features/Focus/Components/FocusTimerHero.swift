import SwiftUI

struct FocusTimerHero: View {
    let seconds: Int
    let progress: Double
    let phase: FocusTimerPhase
    let isRunning: Bool
    let totalSeconds: Int
    let formattedTime: String
    var scale: CGFloat = 1

    private var phaseGradient: [Color] {
        switch phase {
        case .idle:
            return [.appTextSecondary.opacity(0.5), .appAccent.opacity(0.6)]
        case .focus:
            return [.appAccent, .appPrimary]
        case .breakTime:
            return [.appPrimary.opacity(0.7), .appAccent]
        }
    }

    private var phaseLabel: String {
        switch phase {
        case .idle: return "Ready to focus"
        case .focus: return isRunning ? "Deep work in progress" : "Focus paused"
        case .breakTime: return isRunning ? "Take a break" : "Break paused"
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            phaseBadge

            ZStack {
                if isRunning {
                    Circle()
                        .fill(phaseGradient[1].opacity(0.12))
                        .frame(width: 252, height: 252)
                }

                ForEach(0..<12, id: \.self) { tick in
                    Rectangle()
                        .fill(Color.appTextPrimary.opacity(0.12))
                        .frame(width: 2, height: 10)
                        .offset(y: -118)
                        .rotationEffect(.degrees(Double(tick) * 30))
                }

                Circle()
                    .stroke(Color.appSurface.opacity(0.85), lineWidth: 18)
                    .frame(width: 240, height: 240)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: phaseGradient + [phaseGradient[0]],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-90))

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appSurface, Color.appBackground.opacity(0.92)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .overlay {
                        Circle()
                            .stroke(Color.appTextPrimary.opacity(0.06), lineWidth: 1)
                    }

                VStack(spacing: 6) {
                    Text(formattedTime)
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    Text(phaseLabel)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                    if totalSeconds > 0 {
                        Text("\(Int(progress * 100))% complete")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(phaseGradient[0])
                    }
                }
                .padding(.horizontal, 16)
            }
            .scaleEffect(scale)
        }
    }

    private var phaseBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(phaseGradient[0])
                .frame(width: 8, height: 8)
                .opacity(isRunning ? 1 : 0.5)
            Text(phase == .breakTime ? "Break" : phase == .focus ? "Focus" : "Idle")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(Color.appTextPrimary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(phaseGradient[0].opacity(0.2))
        )
        .overlay {
            Capsule(style: .continuous)
                .stroke(phaseGradient[0].opacity(0.4), lineWidth: 1)
        }
    }
}
