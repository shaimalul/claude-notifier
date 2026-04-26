import AppKit
import Foundation
import SwiftUI

struct SettingsWindow: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @State var showResetConfirmation = false
    @State var availableSounds: [String] = []
    @State var selectedIDEOption: IDEOption = .autoDetect
    @State var runningIDEs: [String] = []

    static let systemSoundsPath = "/System/Library/Sounds"
    static let eventTypes: [(key: String, label: String)] = [
        ("permission_prompt", "Permission Request"),
        ("idle_prompt", "Waiting for Input"),
        ("elicitation_dialog", "Input Required"),
        ("unknown", "Other")
    ]
    static let sampleProject = "my-app"
    static let sampleMessage = "Permission requested: Bash"
    static let sampleSessionId = "abc123"
    static let maxActions = 3
    static let showActionId = "SHOW_ACTION"

    var body: some View {
        ScrollView {
            Form {
                generalSection
                soundSection
                notificationsSection
                actionsSection
                ideSection
                aboutSection
            }
            .formStyle(.grouped)
            .padding()
        }
        .frame(width: 520)
        .onAppear {
            loadSounds()
            selectedIDEOption = IDEOption.fromBundleId(settingsStore.settings.ideBundleId)
            refreshRunningIDEs()
        }
    }
}
