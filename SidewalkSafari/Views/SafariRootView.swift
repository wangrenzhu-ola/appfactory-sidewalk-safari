import SwiftUI

struct SafariRootView: View {
    @EnvironmentObject private var store: SafariStore
    @State private var selectedTab: SafariTab = .quests

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { QuestPickerView() }
                .tabItem { Label("Quests", systemImage: "map") }
                .tag(SafariTab.quests)
            NavigationStack { SafariLogView() }
                .tabItem { Label("Safari Log", systemImage: "book.closed") }
                .tag(SafariTab.log)
            NavigationStack { PremiumPreviewView() }
                .tabItem { Label("Premium", systemImage: "sparkles") }
                .tag(SafariTab.premium)
        }
        .tint(SafariStyle.chalkGreen)
    }
}

enum SafariTab: Hashable {
    case quests
    case log
    case premium
}
