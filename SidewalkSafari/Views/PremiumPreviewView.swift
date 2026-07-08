import SwiftUI

struct PremiumPreviewView: View {
    @EnvironmentObject private var store: SafariStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Premium Theme Preview")
                    .font(.largeTitle.bold())
                Text("Theme packs add extra chalk palettes and badge styles. Core quest creation, clue completion, Find Moments, and Safari Log stay usable without purchase.")
                    .foregroundStyle(.secondary)
                PremiumThemeCard()
                storeKitRecovery
            }
            .padding()
        }
        .background(SafariStyle.sidewalk.opacity(0.25))
        .navigationTitle("Premium Preview")
    }

    private var storeKitRecovery: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("StoreKit unavailable", systemImage: "wifi.exclamationmark")
                .font(.headline)
                .foregroundStyle(SafariStyle.chalkAmber)
            Text("Purchases are not confirmed in this build. Keep playing starter quests and try Premium again later.")
                .foregroundStyle(.secondary)
            Button("Try Premium Later") { }
                .buttonStyle(.bordered)
                .accessibilityLabel("Try Premium later. StoreKit unavailable recovery")
        }
        .chalkCard()
    }
}

private struct PremiumThemeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles.rectangle.stack.fill")
                    .font(.largeTitle)
                    .foregroundStyle(SafariStyle.chalkBlue)
                VStack(alignment: .leading) {
                    Text("Chalk Glow Pack")
                        .font(.title2.bold())
                    Text("Preview only until StoreKit confirms purchase.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            HStack {
                ForEach([SafariStyle.chalkGreen, SafariStyle.chalkAmber, SafariStyle.chalkBlue], id: \.self) { color in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color)
                        .frame(height: 56)
                }
            }
        }
        .chalkCard()
        .accessibilityLabel("Premium Theme Preview. Chalk Glow Pack preview only until StoreKit confirms purchase.")
    }
}
