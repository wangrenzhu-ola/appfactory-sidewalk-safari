import XCTest
@testable import SidewalkSafari

@MainActor
final class SafariStoreTests: XCTestCase {
    func testCustomQuestPersistsAndReloads() throws {
        let url = temporaryArchiveURL()
        let store = SafariStore(archiveURL: url)
        store.createQuest(title: "Bus Stop Safari", routeHint: "Walk to the bus stop", cluePrompts: ["Find a blue door", "Hear three street sounds"])

        let reloaded = SafariStore(archiveURL: url)
        XCTAssertTrue(reloaded.quests.contains { $0.title == "Bus Stop Safari" })
        XCTAssertEqual(reloaded.premium.first?.entitlementState, .unavailable)
    }

    func testFindMomentFailureKeepsDraftRecoveryMessage() throws {
        let url = temporaryArchiveURL()
        let store = SafariStore(archiveURL: url)
        let quest = try XCTUnwrap(store.quests.first)
        store.simulateNextSaveFailure = true

        let saved = store.saveFindMoment(quest: quest, note: "Tiny leaf by the curb", mood: .curious, includePhotoPlaceholder: true)

        XCTAssertFalse(saved)
        XCTAssertEqual(store.saveErrorMessage, "Couldn’t save this find moment. Try again.")
        XCTAssertTrue(store.moments.isEmpty)
    }

    func testBadgeProgressAndDeleteQuest() throws {
        let url = temporaryArchiveURL()
        let store = SafariStore(archiveURL: url)
        let quest = try XCTUnwrap(store.quests.first)
        let clue = try XCTUnwrap(quest.clueTiles.first)

        store.setClueStatus(.complete, clue: clue, in: quest)
        let updated = try XCTUnwrap(store.quests.first(where: { $0.id == quest.id }))
        XCTAssertEqual(updated.completedClueCount, 1)
        XCTAssertEqual(store.badges.first?.completedClues, 1)

        store.deleteQuest(updated)
        XCTAssertFalse(store.quests.contains { $0.id == quest.id })
        XCTAssertFalse(store.badges.contains { $0.questId == quest.id })
    }

    private func temporaryArchiveURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("SidewalkSafariTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("safari-log.json")
    }
}
