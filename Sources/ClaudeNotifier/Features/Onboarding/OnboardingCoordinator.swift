import AppKit
import SwiftUI

final class OnboardingCoordinator {
    static let shared = OnboardingCoordinator()

    private static let completedKey = "hasCompletedOnboarding"

    private var window: NSWindow?

    private init() {}

    func presentIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Self.completedKey) else { return }
        presentWindow()
    }

    func complete() {
        UserDefaults.standard.set(true, forKey: Self.completedKey)
        window?.close()
        window = nil
    }

    private func presentWindow() {
        let contentRect = NSRect(x: 0, y: 0, width: 520, height: 420)
        let win = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "Welcome to Claude Notifier"
        win.contentViewController = NSHostingController(rootView: OnboardingRootView())
        win.center()
        win.makeKeyAndOrderFront(nil)
        window = win
    }
}
