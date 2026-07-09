import SwiftUI

struct FindMomentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: SafariStore
    let quest: SidewalkQuest
    @State private var note = ""
    @State private var mood: MoodTag = .curious
    @State private var includePhotoPlaceholder = false

    var body: some View {
        Form {
            Section("Find Moment") {
                TextField("What did you notice?", text: $note, axis: .vertical)
                    .lineLimit(3...6)
                    .accessibilityLabel("Find Moment note")
                Picker("Mood tag", selection: $mood) {
                    ForEach(MoodTag.allCases) { tag in
                        Text(tag.rawValue).tag(tag)
                    }
                }
                Toggle("Add optional local photo placeholder", isOn: $includePhotoPlaceholder)
                    .accessibilityLabel("Optional local photo placeholder")
            }
            Section("Privacy Notice") {
                Label("Find Moments stay on this device. Photo placeholders are optional and are not uploaded.", systemImage: "lock.shield")
                    .foregroundStyle(SafariStyle.chalkGreen)
                    .accessibilityLabel("Privacy Notice. Find Moments stay on this device and are not uploaded.")
            }
            if let error = store.saveErrorMessage {
                Section("Save Status") {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .accessibilityLabel(error)
                }
            }
        }
        .navigationTitle("Find Moment")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .accessibilityLabel("Save Find Moment to Safari Log")
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func save() {
        if store.saveFindMoment(quest: quest, note: note, mood: mood, includePhotoPlaceholder: includePhotoPlaceholder) {
            dismiss()
        }
    }
}
