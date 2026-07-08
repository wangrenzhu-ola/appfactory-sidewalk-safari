import SwiftUI

enum SafariStyle {
    static let sidewalk = Color(red: 0.96, green: 0.92, blue: 0.84)
    static let chalkGreen = Color(red: 0.29, green: 0.55, blue: 0.42)
    static let chalkBlue = Color(red: 0.27, green: 0.55, blue: 0.72)
    static let chalkAmber = Color(red: 0.93, green: 0.62, blue: 0.22)
    static let softInk = Color(red: 0.13, green: 0.17, blue: 0.16)
}

struct ChalkCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.86))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [7, 5]))
                            .foregroundStyle(SafariStyle.chalkGreen.opacity(0.42))
                    )
                    .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
            )
    }
}

extension View {
    func chalkCard() -> some View {
        modifier(ChalkCard())
    }
}

struct ProgressBeads: View {
    let completed: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<max(total, 1), id: \.self) { index in
                Circle()
                    .fill(index < completed ? SafariStyle.chalkGreen : SafariStyle.sidewalk)
                    .overlay(Circle().stroke(SafariStyle.chalkAmber.opacity(0.65), lineWidth: 2))
                    .frame(width: 14, height: 14)
                    .accessibilityLabel(index < completed ? "Completed clue bead" : "Waiting clue bead")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Badge progress: \(completed) of \(total) clue tiles complete")
    }
}

struct SidewalkIllustration: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(SafariStyle.sidewalk)
                .frame(height: 140)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    chalkGlyph("leaf")
                    chalkGlyph("speaker.wave.2")
                    chalkGlyph("door.left.hand.open")
                }
                Text("Pick a starter quest or make your first sidewalk safari.")
                    .font(.headline)
                    .foregroundStyle(SafariStyle.softInk)
            }
            .padding(18)
        }
        .accessibilityLabel("Empty sidewalk illustration with chalk clue glyphs")
    }

    private func chalkGlyph(_ name: String) -> some View {
        Image(systemName: name)
            .font(.title2.weight(.semibold))
            .foregroundStyle(SafariStyle.chalkBlue)
            .frame(width: 44, height: 44)
            .background(Circle().fill(.white.opacity(0.72)))
    }
}
