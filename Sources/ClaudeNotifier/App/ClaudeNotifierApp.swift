import SwiftUI

@main
struct ClaudeNotifierApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Claude Notifier", systemImage: "bell.badge.fill") {
            MenuBarContentView()
                .environmentObject(SettingsStore.shared)
                .environmentObject(NotificationHistory.shared)
        }
        .menuBarExtraStyle(.menu)

    }
}
