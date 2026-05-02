import SwiftUI

@main
struct ClaudeNotifierApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environmentObject(SettingsStore.shared)
                .environmentObject(NotificationHistory.shared)
        } label: {
            Image(nsImage: CNMenuBarIcon.make())
        }
        .menuBarExtraStyle(.menu)
    }
}
