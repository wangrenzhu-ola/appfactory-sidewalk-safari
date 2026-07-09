import Foundation

enum SafariFixtures {
    static let routeKits: [RouteKit] = [
        RouteKit(
            id: "school-walk",
            title: "School Walk",
            subtitle: "Five-minute clues for the way to class.",
            routeHint: "Use a familiar school route and stop only in safe waiting spots.",
            theme: .chalkDaylight,
            cluePrompts: ["Find a backpack color", "Spot a crosswalk symbol", "Hear one morning sound"],
            symbolName: "graduationcap.fill"
        ),
        RouteKit(
            id: "bus-stop",
            title: "Bus Stop",
            subtitle: "Tiny discoveries while you wait.",
            routeHint: "Play near the stop or bench while staying with your grown-up.",
            theme: .soundSteps,
            cluePrompts: ["Find a route number", "Hear the loudest vehicle", "Notice a waiting-line shape"],
            symbolName: "bus.fill"
        ),
        RouteKit(
            id: "park-gate",
            title: "Park Gate",
            subtitle: "Nature clues before the playground.",
            routeHint: "Start at the park entrance and keep the quest on public paths.",
            theme: .tinySigns,
            cluePrompts: ["Find a leaf shadow", "Spot a gate pattern", "Name one bird sound"],
            symbolName: "tree.fill"
        ),
        RouteKit(
            id: "errand-loop",
            title: "Errand Loop",
            subtitle: "A quick quest for shop or library walks.",
            routeHint: "Use a short errand route with clear grown-up checkpoints.",
            theme: .chalkDaylight,
            cluePrompts: ["Find a window sign", "Spot a round handle", "Hear a checkout sound"],
            symbolName: "bag.fill"
        )
    ]

    static func starterQuests(now: Date = Date()) -> [SidewalkQuest] {
        [
            makeQuest(
                title: "Color Hunt",
                routeHint: "Look along a familiar block or walk to school.",
                theme: .chalkDaylight,
                prompts: [
                    ("Find a blue door", "Try porches, gates, and murals."),
                    ("Spot a red sign", "Street signs and shop windows count."),
                    ("Point to something sunny yellow", "Leaves, bikes, or painted curbs all work.")
                ],
                now: now
            ),
            makeQuest(
                title: "Sound Steps",
                routeHint: "Listen for tiny sidewalk sounds between corners.",
                theme: .soundSteps,
                prompts: [
                    ("Hear three street sounds", "Pause safely before crossing."),
                    ("Copy a bird rhythm", "Tap it quietly on your palm."),
                    ("Find the quietest corner", "Use a whisper voice there.")
                ],
                now: now
            ),
            makeQuest(
                title: "Tiny Signs",
                routeHint: "Search for helpful marks on a short errand route.",
                theme: .tinySigns,
                prompts: [
                    ("Find a house number", "No need to read private names."),
                    ("Spot a bus stop symbol", "Any public wayfinding sign works."),
                    ("Notice one sidewalk crack shape", "Name the shape together.")
                ],
                now: now
            )
        ]
    }

    static func makeCustomQuest(title: String, routeHint: String, prompts: [String], theme: SafariTheme = .chalkDaylight) -> SidewalkQuest {
        let id = UUID()
        let now = Date()
        return SidewalkQuest(
            id: id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "My Sidewalk Safari" : title,
            routeHint: routeHint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Choose a safe, familiar short walk." : routeHint,
            theme: theme,
            clueTiles: prompts.enumerated().map { index, prompt in
                ClueTile(id: UUID(), questId: id, prompt: prompt, status: .waiting, order: index, optionalHint: nil)
            },
            createdAt: now,
            updatedAt: now,
            isStarter: false
        )
    }

    private static func makeQuest(title: String, routeHint: String, theme: SafariTheme, prompts: [(String, String)], now: Date) -> SidewalkQuest {
        let id = UUID()
        return SidewalkQuest(
            id: id,
            title: title,
            routeHint: routeHint,
            theme: theme,
            clueTiles: prompts.enumerated().map { index, clue in
                ClueTile(id: UUID(), questId: id, prompt: clue.0, status: .waiting, order: index, optionalHint: clue.1)
            },
            createdAt: now,
            updatedAt: now,
            isStarter: true
        )
    }
}
