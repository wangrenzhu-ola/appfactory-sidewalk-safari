import SwiftUI

struct QuestPickerView: View {
    @EnvironmentObject private var store: SafariStore
    @State private var isShowingCreateQuest = false
    @State private var selectedQuestID: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                OnboardingCard()
                if store.quests.isEmpty {
                    EmptyQuestShelf(onRestore: store.restoreStarterQuestsIfNeeded, onCreate: { isShowingCreateQuest = true })
                } else {
                    starterSection
                    customSection
                }
                Button("Create Custom Quest", systemImage: "plus.circle.fill") {
                    isShowingCreateQuest = true
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Create Custom Quest")
            }
            .padding()
        }
        .background(SafariStyle.sidewalk.opacity(0.28))
        .navigationTitle("Sidewalk Safari")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Fresh Install") { store.resetForFreshInstall() }
                    .accessibilityLabel("Show empty Quest Picker state")
            }
        }
        .sheet(isPresented: $isShowingCreateQuest) {
            NavigationStack { CreateQuestView() }
        }
        .navigationDestination(item: $selectedQuestID) { questID in
            QuestRunView(questID: questID)
        }
    }

    private var starterSection: some View {
        QuestSection(title: "Starter Quests", subtitle: "Local starter content for a short familiar walk.") {
            ForEach(store.quests.filter(\.isStarter)) { quest in
                QuestShelfCard(quest: quest) { selectedQuestID = quest.id }
            }
        }
    }

    private var customSection: some View {
        QuestSection(title: "My Sidewalk Quests", subtitle: "Editable clue tiles saved on this device.") {
            if store.customQuests.isEmpty {
                Text("Make a custom sidewalk safari when your route needs its own clues.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .chalkCard()
            } else {
                ForEach(store.customQuests) { quest in
                    QuestShelfCard(quest: quest) { selectedQuestID = quest.id }
                }
            }
        }
    }
}

private struct OnboardingCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Turn a short walk into a sidewalk quest.")
                .font(.largeTitle.bold())
                .foregroundStyle(SafariStyle.softInk)
            Text("Choose a starter quest, edit clue tiles, save Find Moments, and keep the Safari Log local on this device.")
                .font(.body)
                .foregroundStyle(.secondary)
            Label("Local starter content — no live community cache, no child tracking, no AI service.", systemImage: "lock.shield")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(SafariStyle.chalkGreen)
        }
        .chalkCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Onboarding. Turn a short walk into a sidewalk quest. Local starter content.")
    }
}

private struct EmptyQuestShelf: View {
    let onRestore: () -> Void
    let onCreate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SidewalkIllustration()
            HStack {
                Button("Choose Starter Quests", action: onRestore)
                    .buttonStyle(.borderedProminent)
                Button("Create Quest", action: onCreate)
                    .buttonStyle(.bordered)
            }
        }
    }
}

private struct QuestSection<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title2.bold())
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            content
        }
    }
}

private struct QuestShelfCard: View {
    let quest: SidewalkQuest
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: quest.isStarter ? "figure.walk.circle.fill" : "pencil.and.list.clipboard")
                    .font(.title)
                    .foregroundStyle(quest.isStarter ? SafariStyle.chalkBlue : SafariStyle.chalkAmber)
                VStack(alignment: .leading, spacing: 6) {
                    Text(quest.title).font(.headline)
                    Text(quest.routeHint).font(.subheadline).foregroundStyle(.secondary)
                    ProgressBeads(completed: quest.completedClueCount, total: quest.clueTiles.count)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .chalkCard()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open \(quest.title) sidewalk quest")
    }
}

struct CreateQuestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: SafariStore
    @State private var title = ""
    @State private var routeHint = ""
    @State private var clueOne = "Find a red door"
    @State private var clueTwo = "Hear three street sounds"
    @State private var clueThree = "Spot a sidewalk shape"

    var body: some View {
        Form {
            Section("Quest") {
                TextField("Quest title", text: $title)
                    .accessibilityLabel("Quest title")
                TextField("Route hint", text: $routeHint, axis: .vertical)
                    .accessibilityLabel("Route hint")
            }
            Section("Clue Tiles") {
                Text("Add this clue to the safari?")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(SafariStyle.chalkAmber)
                TextField("First clue tile", text: $clueOne)
                TextField("Second clue tile", text: $clueTwo)
                TextField("Third clue tile", text: $clueThree)
            }
        }
        .navigationTitle("Create Quest")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .accessibilityLabel("Save custom sidewalk safari")
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func save() {
        store.createQuest(title: title, routeHint: routeHint, cluePrompts: [clueOne, clueTwo, clueThree])
        dismiss()
    }
}
