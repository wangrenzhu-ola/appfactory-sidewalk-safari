import SwiftUI

@main
struct SidewalkSafariApp: App {
    @StateObject private var store = SafariStore()

    var body: some Scene {
        WindowGroup {
            SafariRootView()
                .environmentObject(store)
        }
    }
}
