import SwiftUI

struct FocusSessionCardCell: View {
    let session: FocusSessionRecord
    var isFirst: Bool = false
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            timelineIndicator

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.linkedTaskTitle ?? "Focus Session")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                        Text(session.completedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Spacer()
                    durationBadge
                }

                if session.linkedTaskTitle != nil {
                    MetaTag(text: "Linked task", icon: "link", style: .accent)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCellSurface(accent: .appAccent, tintStrength: 0.04)
        }
        .padding(.leading, 4)
    }

    private var timelineIndicator: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(isFirst ? Color.clear : Color.appAccent.opacity(0.3))
                .frame(width: 2, height: 12)
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.appAccent.opacity(0.3), .appPrimary.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                Image(systemName: "checkmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.appPrimary)
            }
            Rectangle()
                .fill(isLast ? Color.clear : Color.appAccent.opacity(0.3))
                .frame(width: 2)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 28)
    }

    private var durationBadge: some View {
        VStack(spacing: 2) {
            Text("\(session.durationMinutes)")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appPrimary)
            Text("min")
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.appPrimary.opacity(0.14))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.appPrimary.opacity(0.25), lineWidth: 1)
                )
        )
    }
}
