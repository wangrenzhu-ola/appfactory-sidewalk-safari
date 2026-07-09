import Foundation

struct SidewalkQuest: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var routeHint: String
    var theme: SafariTheme
    var clueTiles: [ClueTile]
    var createdAt: Date
    var updatedAt: Date
    var isStarter: Bool

    var completedClueCount: Int {
        clueTiles.filter { $0.status == .complete }.count
    }

    var badgeName: String {
        completedClueCount == clueTiles.count && !clueTiles.isEmpty ? "Sidewalk Scout" : "Trail Starter"
    }
}

struct ClueTile: Identifiable, Codable, Equatable {
    var id: UUID
    var questId: UUID
    var prompt: String
    var status: ClueStatus
    var order: Int
    var optionalHint: String?
}

enum ClueStatus: String, Codable, CaseIterable, Equatable {
    case waiting
    case complete
    case skipped
}

struct FindMoment: Identifiable, Codable, Equatable {
    var id: UUID
    var questId: UUID
    var note: String
    var optionalPhotoLocalIdentifier: String?
    var moodTag: MoodTag
    var savedAt: Date
}

struct BadgeProgress: Identifiable, Codable, Equatable {
    var id: UUID { questId }
    var questId: UUID
    var completedClues: Int
    var badgeName: String
    var replayCount: Int
}


struct RouteKit: Identifiable, Equatable {
    var id: String
    var title: String
    var subtitle: String
    var routeHint: String
    var theme: SafariTheme
    var cluePrompts: [String]
    var symbolName: String
}

struct WalkRecap: Equatable {
    var completedClues: Int
    var skippedClues: Int
    var totalClues: Int
    var findMoments: Int
    var replayCount: Int
    var nextStep: String

    var summaryLine: String {
        "\(completedClues) completed • \(skippedClues) skipped • \(findMoments) Find Moments"
    }
}

struct PremiumEntitlementCache: Identifiable, Codable, Equatable {
    var id: String { themePackId }
    var themePackId: String
    var entitlementState: EntitlementState
    var lastCheckedAt: Date
}

enum EntitlementState: String, Codable, Equatable {
    case unavailable
    case notPurchased
    case pending
    case active
}

enum MoodTag: String, Codable, CaseIterable, Identifiable, Equatable {
    case curious = "Curious"
    case proud = "Proud"
    case silly = "Silly"
    case calm = "Calm"

    var id: String { rawValue }
}

enum SafariTheme: String, Codable, CaseIterable, Identifiable, Equatable {
    case chalkDaylight = "Chalk Daylight"
    case soundSteps = "Sound Steps"
    case tinySigns = "Tiny Signs"
    case premiumGlow = "Premium Glow"

    var id: String { rawValue }
}

struct SafariArchive: Codable, Equatable {
    var quests: [SidewalkQuest]
    var moments: [FindMoment]
    var badges: [BadgeProgress]
    var premium: [PremiumEntitlementCache]
}
