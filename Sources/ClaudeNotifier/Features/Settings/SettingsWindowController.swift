import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    static let shared = SettingsWindowController()

    private init() {
        let window = Self.makeWindow()
        let hosting = Self.makeHostingView()
        let blur = Self.makeBlurView(hosting: hosting)
        window.contentView = blur
        super.init(window: window)
        window.delegate = self
    }

    private static func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 680),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Claude Notifier Settings"
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.center()
        window.isReleasedWhenClosed = false
        return window
    }

    private static func makeHostingView() -> NSHostingView<AnyView> {
        let content = AnyView(SettingsWindow().environmentObject(SettingsStore.shared))
        let hosting = NSHostingView(rootView: content)
        hosting.sizingOptions = .preferredContentSize
        return hosting
    }

    private static func makeBlurView(hosting: NSView) -> NSVisualEffectView {
        let blur = NSVisualEffectView(frame: .zero)
        blur.material = .sidebar
        blur.blendingMode = .behindWindow
        blur.state = .active
        blur.autoresizingMask = [.width, .height]
        blur.addSubview(hosting)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            hosting.topAnchor.constraint(equalTo: blur.topAnchor),
            hosting.bottomAnchor.constraint(equalTo: blur.bottomAnchor)
        ])
        return blur
    }

    required init?(coder _: NSCoder) { nil }

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
