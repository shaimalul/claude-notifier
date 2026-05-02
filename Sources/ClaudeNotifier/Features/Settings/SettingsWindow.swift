import AppKit
import Foundation
import SwiftUI
import UserNotifications

struct SettingsWindow: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @State var showResetConfirmation = false
    @State var availableSounds: [String] = []
    @State var selectedIDEOption: IDEOption = .autoDetect
    @State var runningIDEs: [String] = []
    @State var notificationPermission: UNAuthorizationStatus = .notDetermined
    @State var accessibilityGranted = false

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
        VStack(spacing: 0) {
            appHeader
            Divider().opacity(0.3)
            ScrollView {
                Form {
                    permissionsSection
                    generalSection
                    soundSection
                    notificationsSection
                    actionsSection
                    ideSection
                    aboutSection
                }
                .formStyle(.grouped)
                .padding(.vertical, 4)
            }
        }
        .background(.clear)
        .frame(width: 520)
        .padding(.top, 28)
        .onAppear {
            loadSounds()
            selectedIDEOption = IDEOption.fromBundleId(settingsStore.settings.ideBundleId)
            refreshRunningIDEs()
            refreshPermissions()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
        ) { _ in refreshPermissions() }
    }

    private var appHeader: some View {
        HStack(spacing: 14) {
            brandIcon
            VStack(alignment: .leading, spacing: 2) {
                Text("Claude Notifier")
                    .font(.system(size: 16, weight: .semibold))
                Text("Menu bar alerts for Claude Code")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("v\(appVersion)")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.brandPrimary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .foregroundColor(.brandPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var brandIcon: some View {
        CNLogo(size: 48)
            .shadow(color: Color.iconBackground.opacity(0.5), radius: 6, x: 0, y: 3)
    }
}
