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


    func testRouteKitCreatesEditableCustomQuest() throws {
        let url = temporaryArchiveURL()
        let store = SafariStore(archiveURL: url)
        let kit = try XCTUnwrap(store.routeKits.first { $0.id == "school-walk" })

        store.createQuest(from: kit)

        let created = try XCTUnwrap(store.customQuests.first { $0.title == "Today’s School Walk" })
        XCTAssertFalse(created.isStarter)
        XCTAssertEqual(created.routeHint, kit.routeHint)
        XCTAssertEqual(created.clueTiles.map(\.prompt), kit.cluePrompts)
        XCTAssertEqual(created.clueTiles.map(\.status), [.waiting, .waiting, .waiting])
    }

    func testCopyQuestResetsClueStatusAndPersists() throws {
        let url = temporaryArchiveURL()
        let store = SafariStore(archiveURL: url)
        let quest = try XCTUnwrap(store.quests.first)
        let clue = try XCTUnwrap(quest.clueTiles.first)
        store.setClueStatus(.complete, clue: clue, in: quest)
        let progressed = try XCTUnwrap(store.quests.first(where: { $0.id == quest.id }))

        store.copyQuest(progressed)

        let copied = try XCTUnwrap(store.customQuests.first { $0.title == "Copy of \(quest.title)" })
        XCTAssertFalse(copied.isStarter)
        XCTAssertEqual(copied.clueTiles.map(\.prompt), progressed.clueTiles.sorted { $0.order < $1.order }.map(\.prompt))
        XCTAssertEqual(copied.clueTiles.map(\.status), Array(repeating: .waiting, count: copied.clueTiles.count))

        let reloaded = SafariStore(archiveURL: url)
        XCTAssertTrue(reloaded.customQuests.contains { $0.title == copied.title })
    }

    func testWalkRecapCountsProgressMomentsAndReplays() throws {
        let url = temporaryArchiveURL()
        let store = SafariStore(archiveURL: url)
        let quest = try XCTUnwrap(store.quests.first)
        let firstClue = try XCTUnwrap(quest.clueTiles.first)
        let secondClue = try XCTUnwrap(quest.clueTiles.dropFirst().first)
        store.setClueStatus(.complete, clue: firstClue, in: quest)
        let afterComplete = try XCTUnwrap(store.quests.first(where: { $0.id == quest.id }))
        store.setClueStatus(.skipped, clue: secondClue, in: afterComplete)
        let afterSkip = try XCTUnwrap(store.quests.first(where: { $0.id == quest.id }))
        XCTAssertTrue(store.saveFindMoment(quest: afterSkip, note: "Blue gate", mood: .proud, includePhotoPlaceholder: false))
        store.replay(afterSkip)

        let latest = try XCTUnwrap(store.quests.first(where: { $0.id == quest.id }))
        let recap = store.walkRecap(for: latest)
        XCTAssertEqual(recap.completedClues, 1)
        XCTAssertEqual(recap.skippedClues, 1)
        XCTAssertEqual(recap.findMoments, 1)
        XCTAssertEqual(recap.replayCount, 1)
        XCTAssertEqual(recap.summaryLine, "1 completed • 1 skipped • 1 Find Moments")
    }

    private func temporaryArchiveURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("SidewalkSafariTests")
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("safari-log.json")
    }
}
