import AppKit
import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var notificationHistory: NotificationHistory

    private static let messageTruncationLength = 30

    var body: some View {
        if !notificationHistory.recent.isEmpty {
            Section("Recent") {
                ForEach(notificationHistory.recent) { notification in
                    Button(rowTitle(for: notification)) {
                        copyToPasteboard(notification.cwd)
                    }
                }
            }
            Divider()
        }

        if ActionDispatcher.shared.isSnoozed {
            Text("Snoozed")
                .foregroundColor(.red)
            Divider()
        }

        Button(settingsStore.settings.isPaused ? "Resume Notifications" : "Pause Notifications") {
            settingsStore.settings.isPaused.toggle()
        }

        Button(launchAtLoginTitle) {
            toggleLaunchAtLogin()
        }

        Divider()

        Button("Open Settings...") {
            openSettingsWindow()
        }

        Divider()

        Button("Quit") {
            NSApp.terminate(nil)
        }
    }

    private var launchAtLoginTitle: String {
        LaunchAtLoginService.shared.isEnabled ? "Disable Launch at Login" : "Launch at Login"
    }

    private func rowTitle(for notification: ClaudeNotification) -> String {
        let truncated = truncate(notification.message, to: Self.messageTruncationLength)
        return "\(notification.projectName): \(truncated)"
    }

    private func truncate(_ value: String, to length: Int) -> String {
        guard value.count > length else { return value }
        return String(value.prefix(length)) + "..."
    }

    private func copyToPasteboard(_ value: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
    }

    private func toggleLaunchAtLogin() {
        let newValue = !LaunchAtLoginService.shared.isEnabled
        try? LaunchAtLoginService.shared.setEnabled(newValue)
        settingsStore.settings.launchAtLogin = newValue
    }

    private func openSettingsWindow() {
        SettingsWindowController.shared.show()
    }
}
