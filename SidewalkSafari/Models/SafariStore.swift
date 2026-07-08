import Foundation
import SwiftUI

@MainActor
final class SafariStore: ObservableObject {
    @Published private(set) var quests: [SidewalkQuest] = []
    @Published private(set) var moments: [FindMoment] = []
    @Published private(set) var badges: [BadgeProgress] = []
    @Published private(set) var premium: [PremiumEntitlementCache] = []
    @Published var saveErrorMessage: String?
    @Published var lastSuccessMessage: String?
    @Published var simulateNextSaveFailure = false

    private let archiveURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(archiveURL: URL? = nil) {
        let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        self.archiveURL = archiveURL ?? supportDirectory.appending(path: "SidewalkSafari/safari-log.json")
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        load()
    }

    var customQuests: [SidewalkQuest] {
        quests.filter { !$0.isStarter }
    }

    var completedQuests: [SidewalkQuest] {
        quests.filter { quest in
            quest.completedClueCount > 0 || moments.contains(where: { $0.questId == quest.id })
        }
    }

    func resetForFreshInstall() {
        quests = []
        moments = []
        badges = []
        premium = [PremiumEntitlementCache(themePackId: "chalk-glow-pack", entitlementState: .unavailable, lastCheckedAt: Date())]
        persist()
    }

    func restoreStarterQuestsIfNeeded() {
        if quests.isEmpty {
            quests = SafariFixtures.starterQuests()
            persist()
        }
    }

    func createQuest(title: String, routeHint: String, cluePrompts: [String]) {
        let usablePrompts = cluePrompts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let quest = SafariFixtures.makeCustomQuest(
            title: title,
            routeHint: routeHint,
            prompts: usablePrompts.isEmpty ? ["Find a friendly front door", "Notice a sidewalk shape", "Hear one neighborhood sound"] : usablePrompts
        )
        quests.insert(quest, at: 0)
        lastSuccessMessage = "Custom sidewalk safari saved."
        persist()
    }

    func updateQuest(_ quest: SidewalkQuest, title: String, routeHint: String) {
        guard let index = quests.firstIndex(where: { $0.id == quest.id }) else { return }
        quests[index].title = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? quest.title : title
        quests[index].routeHint = routeHint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? quest.routeHint : routeHint
        quests[index].updatedAt = Date()
        lastSuccessMessage = "Review your sidewalk clues before the walk."
        persist()
    }

    func updateClue(_ clue: ClueTile, in quest: SidewalkQuest, prompt: String, optionalHint: String?) {
        guard let questIndex = quests.firstIndex(where: { $0.id == quest.id }),
              let clueIndex = quests[questIndex].clueTiles.firstIndex(where: { $0.id == clue.id }) else { return }
        quests[questIndex].clueTiles[clueIndex].prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? clue.prompt : prompt
        quests[questIndex].clueTiles[clueIndex].optionalHint = optionalHint
        quests[questIndex].updatedAt = Date()
        persist()
    }

    func setClueStatus(_ status: ClueStatus, clue: ClueTile, in quest: SidewalkQuest) {
        guard let questIndex = quests.firstIndex(where: { $0.id == quest.id }),
              let clueIndex = quests[questIndex].clueTiles.firstIndex(where: { $0.id == clue.id }) else { return }
        quests[questIndex].clueTiles[clueIndex].status = status
        quests[questIndex].updatedAt = Date()
        updateBadge(for: quests[questIndex])
        persist()
    }

    func saveFindMoment(quest: SidewalkQuest, note: String, mood: MoodTag, includePhotoPlaceholder: Bool) -> Bool {
        if simulateNextSaveFailure {
            simulateNextSaveFailure = false
            saveErrorMessage = "Couldn’t save this find moment. Try again."
            return false
        }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let moment = FindMoment(
            id: UUID(),
            questId: quest.id,
            note: trimmedNote.isEmpty ? "We found a tiny sidewalk detail." : trimmedNote,
            optionalPhotoLocalIdentifier: includePhotoPlaceholder ? "local-photo-placeholder" : nil,
            moodTag: mood,
            savedAt: Date()
        )
        moments.insert(moment, at: 0)
        updateBadge(for: quest)
        saveErrorMessage = nil
        lastSuccessMessage = "Find moment saved to Safari Log."
        persist()
        return true
    }

    func replay(_ quest: SidewalkQuest) {
        guard let index = badges.firstIndex(where: { $0.questId == quest.id }) else { return }
        badges[index].replayCount += 1
        persist()
    }

    func deleteQuest(_ quest: SidewalkQuest) {
        quests.removeAll { $0.id == quest.id }
        moments.removeAll { $0.questId == quest.id }
        badges.removeAll { $0.questId == quest.id }
        lastSuccessMessage = "Sidewalk safari deleted."
        persist()
    }

    private func updateBadge(for quest: SidewalkQuest) {
        let progress = BadgeProgress(
            questId: quest.id,
            completedClues: quest.completedClueCount,
            badgeName: quest.badgeName,
            replayCount: badges.first(where: { $0.questId == quest.id })?.replayCount ?? 0
        )
        if let index = badges.firstIndex(where: { $0.questId == quest.id }) {
            badges[index] = progress
        } else {
            badges.insert(progress, at: 0)
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: archiveURL)
            let archive = try decoder.decode(SafariArchive.self, from: data)
            quests = archive.quests
            moments = archive.moments
            badges = archive.badges
            premium = archive.premium.isEmpty ? defaultPremium() : archive.premium
        } catch {
            quests = SafariFixtures.starterQuests()
            moments = []
            badges = []
            premium = defaultPremium()
            persist()
        }
    }

    private func persist() {
        do {
            try FileManager.default.createDirectory(at: archiveURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let archive = SafariArchive(quests: quests, moments: moments, badges: badges, premium: premium)
            try encoder.encode(archive).write(to: archiveURL, options: [.atomic])
        } catch {
            saveErrorMessage = "Couldn’t save this find moment. Try again."
        }
    }

    private func defaultPremium() -> [PremiumEntitlementCache] {
        [PremiumEntitlementCache(themePackId: "chalk-glow-pack", entitlementState: .unavailable, lastCheckedAt: Date())]
    }
}
