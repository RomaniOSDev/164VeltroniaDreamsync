import Foundation

struct TimerPreset: Identifiable, Equatable {
    let id: String
    let name: String
    let focusMinutes: Int
    let breakMinutes: Int

    static let all: [TimerPreset] = [
        TimerPreset(id: "pomodoro", name: "Pomodoro", focusMinutes: 25, breakMinutes: 5),
        TimerPreset(id: "deep_work", name: "Deep Work", focusMinutes: 50, breakMinutes: 10),
        TimerPreset(id: "custom", name: "Custom", focusMinutes: 25, breakMinutes: 5)
    ]

    static func preset(id: String, focus: Int, breakMin: Int) -> TimerPreset {
        TimerPreset(id: id, name: "Custom", focusMinutes: focus, breakMinutes: breakMin)
    }

    var iconName: String {
        switch id {
        case "pomodoro": return "timer"
        case "deep_work": return "bolt.fill"
        default: return "slider.horizontal.3"
        }
    }

    var subtitle: String {
        "\(focusMinutes) min focus · \(breakMinutes) min break"
    }
}
