import SwiftUI

struct QuestRunView: View {
    @EnvironmentObject private var store: SafariStore
    let questID: UUID
    @State private var editingClue: ClueTile?
    @State private var isEditingQuest = false
    @State private var isSavingMoment = false

    private var quest: SidewalkQuest? {
        store.quests.first(where: { $0.id == questID })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let quest {
                    QuestRunHeader(quest: quest)
                    WalkRecapCard(recap: store.walkRecap(for: quest))
                    ForEach(quest.clueTiles.sorted { $0.order < $1.order }) { clue in
                        ClueTileCard(
                            clue: clue,
                            onComplete: { store.setClueStatus(.complete, clue: clue, in: quest) },
                            onSkip: { store.setClueStatus(.skipped, clue: clue, in: quest) },
                            onEdit: { editingClue = clue }
                        )
                    }
                    Button("Save Find Moment", systemImage: "sparkle.magnifyingglass") { isSavingMoment = true }
                        .buttonStyle(.borderedProminent)
                        .accessibilityLabel("Save Find Moment")
                    if let message = store.lastSuccessMessage {
                        Label(message, systemImage: "checkmark.seal.fill")
                            .foregroundStyle(SafariStyle.chalkGreen)
                            .accessibilityLabel(message)
                    }
                } else {
                    ContentUnavailableView("Quest not found", systemImage: "exclamationmark.triangle", description: Text("Pick another sidewalk quest from the Quest Picker."))
                }
            }
            .padding()
        }
        .background(SafariStyle.sidewalk.opacity(0.24))
        .navigationTitle(quest?.title ?? "Quest Run")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit Quest") { isEditingQuest = true }
                    .disabled(quest == nil)
                    .accessibilityLabel("Edit Quest route hint")
            }
        }
        .sheet(item: $editingClue) { clue in
            if let quest {
                NavigationStack { EditClueView(quest: quest, clue: clue) }
            }
        }
        .sheet(isPresented: $isEditingQuest) {
            if let quest {
                NavigationStack { EditQuestView(quest: quest) }
            }
        }
        .sheet(isPresented: $isSavingMoment) {
            if let quest {
                NavigationStack { FindMomentView(quest: quest) }
            }
        }
    }
}

private struct QuestRunHeader: View {
    let quest: SidewalkQuest

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(quest.theme.rawValue, systemImage: "sun.max")
                .foregroundStyle(SafariStyle.chalkAmber)
            Text(quest.routeHint)
                .font(.title3.weight(.semibold))
            ProgressBeads(completed: quest.completedClueCount, total: quest.clueTiles.count)
        }
        .chalkCard()
    }
}

private struct WalkRecapCard: View {
    let recap: WalkRecap

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Walk Recap", systemImage: "list.bullet.clipboard")
                .font(.headline)
                .foregroundStyle(SafariStyle.chalkBlue)
            HStack(spacing: 14) {
                RecapMetric(value: "\(recap.completedClues)/\(recap.totalClues)", label: "clues")
                RecapMetric(value: "\(recap.skippedClues)", label: "skipped")
                RecapMetric(value: "\(recap.findMoments)", label: "moments")
                RecapMetric(value: "\(recap.replayCount)", label: "replays")
            }
            Text(recap.nextStep)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .chalkCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Walk Recap. \(recap.summaryLine). \(recap.nextStep)")
    }
}

private struct RecapMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.headline.monospacedDigit())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ClueTileCard: View {
    let clue: ClueTile
    let onComplete: () -> Void
    let onSkip: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                statusIcon
                Text(clue.prompt)
                    .font(.headline)
                Spacer()
            }
            if let hint = clue.optionalHint, !hint.isEmpty {
                Text(hint).font(.subheadline).foregroundStyle(.secondary)
            }
            HStack {
                Button("Complete", systemImage: "checkmark.circle", action: onComplete)
                    .buttonStyle(.borderedProminent)
                Button("Skip", systemImage: "forward", action: onSkip)
                    .buttonStyle(.bordered)
                Button("Edit", systemImage: "pencil", action: onEdit)
                    .buttonStyle(.bordered)
            }
        }
        .chalkCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Clue Tile. \(clue.prompt). Status \(clue.status.rawValue).")
    }

    private var statusIcon: some View {
        Image(systemName: clue.status == .complete ? "checkmark.seal.fill" : clue.status == .skipped ? "forward.circle" : "circle.dashed")
            .foregroundStyle(clue.status == .complete ? SafariStyle.chalkGreen : SafariStyle.chalkBlue)
            .font(.title3)
    }
}

struct EditQuestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: SafariStore
    let quest: SidewalkQuest
    @State private var title: String
    @State private var routeHint: String

    init(quest: SidewalkQuest) {
        self.quest = quest
        _title = State(initialValue: quest.title)
        _routeHint = State(initialValue: quest.routeHint)
    }

    var body: some View {
        Form {
            Section("Review your sidewalk clues before the walk.") {
                TextField("Quest title", text: $title)
                TextField("Route hint", text: $routeHint, axis: .vertical)
            }
        }
        .navigationTitle("Edit Quest")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) { Button("Save") { save() } }
        }
    }

    private func save() {
        store.updateQuest(quest, title: title, routeHint: routeHint)
        dismiss()
    }
}

struct EditClueView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: SafariStore
    let quest: SidewalkQuest
    let clue: ClueTile
    @State private var prompt: String
    @State private var hint: String

    init(quest: SidewalkQuest, clue: ClueTile) {
        self.quest = quest
        self.clue = clue
        _prompt = State(initialValue: clue.prompt)
        _hint = State(initialValue: clue.optionalHint ?? "")
    }

    var body: some View {
        Form {
            Section("Add this clue to the safari?") {
                TextField("Clue prompt", text: $prompt)
                TextField("Optional hint", text: $hint)
            }
        }
        .navigationTitle("Edit Clue Tile")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) { Button("Save") { save() } }
        }
    }

    private func save() {
        store.updateClue(clue, in: quest, prompt: prompt, optionalHint: hint)
        dismiss()
    }
}
