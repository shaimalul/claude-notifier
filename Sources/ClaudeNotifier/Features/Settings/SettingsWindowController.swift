import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    static let shared = SettingsWindowController()

    private init() {
        let content = SettingsWindow().environmentObject(SettingsStore.shared)
        let hosting = NSHostingView(rootView: content)
        hosting.sizingOptions = .preferredContentSize

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 600),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Claude Notifier Settings"
        window.contentView = hosting
        window.center()
        window.isReleasedWhenClosed = false

        super.init(window: window)
        window.delegate = self
    }

    required init?(coder _: NSCoder) {
        nil
    }

    func show() {
        NSApp.setActivationPolicy(.regular)
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
