import SwiftUI

struct SafariLogView: View {
    @EnvironmentObject private var store: SafariStore
    @State private var pendingDelete: SidewalkQuest?
    @State private var replayQuest: SidewalkQuest?

    var body: some View {
        List {
            if loggedQuests.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Safari Log yet",
                        systemImage: "book.closed",
                        description: Text("Complete a Clue Tile and save a Find Moment to start your local badge strip.")
                    )
                    .accessibilityLabel("Safari Log empty. Complete a Clue Tile and save a Find Moment.")
                }
            } else {
                Section("Badge Strip") {
                    BadgeStrip(badges: store.badges)
                }
                Section("Completed Quests") {
                    ForEach(loggedQuests) { quest in
                        SafariLogRow(
                            quest: quest,
                            recap: store.walkRecap(for: quest),
                            onReplay: { replay(quest) },
                            onDelete: { requestDelete(quest) }
                        )
                    }
                }
            }
        }
        .navigationTitle("Safari Log")
        .alert("Replay started", isPresented: Binding(get: { replayQuest != nil }, set: { if !$0 { replayQuest = nil } })) {
            Button("OK", role: .cancel) { replayQuest = nil }
        } message: {
            Text("This sidewalk safari is ready to run again from your saved clue tiles.")
        }
        .confirmationDialog(
            "Delete this sidewalk safari?",
            isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
            titleVisibility: .visible
        ) {
            if let quest = pendingDelete {
                Button("Delete \(quest.title)", role: .destructive) { store.deleteQuest(quest) }
            }
            Button("Cancel", role: .cancel) { pendingDelete = nil }
        } message: {
            if let quest = pendingDelete {
                Text("This removes \(quest.completedClueCount) completed clue tiles and saved Find Moments from this device.")
            }
        }
    }

    private var loggedQuests: [SidewalkQuest] {
        store.quests.filter { quest in
            quest.completedClueCount > 0 || store.moments.contains(where: { $0.questId == quest.id })
        }
    }

    private func replay(_ quest: SidewalkQuest) {
        store.replay(quest)
        replayQuest = quest
    }

    private func requestDelete(_ quest: SidewalkQuest) {
        pendingDelete = quest
    }
}

private struct BadgeStrip: View {
    let badges: [BadgeProgress]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(badges) { badge in
                    VStack(spacing: 4) {
                        Image(systemName: "seal.fill")
                            .font(.title2)
                            .foregroundStyle(SafariStyle.chalkAmber)
                        Text(badge.badgeName)
                            .font(.caption.bold())
                        Text("\(badge.completedClues) clues")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 16).fill(SafariStyle.sidewalk.opacity(0.6)))
                }
            }
        }
        .accessibilityLabel("Safari Log badge strip")
    }
}

private struct SafariLogRow: View {
    let quest: SidewalkQuest
    let recap: WalkRecap
    let onReplay: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quest.title).font(.headline)
            Text(recap.summaryLine)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(recap.nextStep)
                .font(.caption)
                .foregroundStyle(SafariStyle.chalkGreen)
            HStack {
                Button("Replay", systemImage: "arrow.clockwise", action: onReplay)
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            }
            .buttonStyle(.bordered)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Safari Log entry for \(quest.title). \(recap.summaryLine).")
    }
}
