import AppKit
import Foundation

// Cache the key at file scope to avoid repeated retain/release calls
private let kAXTrustedKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String

final class WindowFocusHandler: WindowFocusProtocol {
    static let shared = WindowFocusHandler()

    private let logger: LoggerProtocol

    init(logger: LoggerProtocol = Logger.shared) {
        self.logger = logger
    }

    func focusCursorWindow(forProjectPath path: String) {
        logger.log("Attempting to focus Cursor for path: \(path)", category: "WindowFocus")

        activateCursorApp()

        let projectName = URL(fileURLWithPath: path).lastPathComponent
        if focusWindowUsingAccessibility(projectName: projectName) {
            logger.log("Focused specific window: \(projectName)", category: "WindowFocus")
        } else {
            logger.log("Could not focus specific window, but Cursor is activated", category: "WindowFocus")
        }
    }

    func checkAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedKey: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func requestAccessibilityPermissions() {
        let options = [kAXTrustedKey: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    private func focusWindowUsingAccessibility(projectName: String) -> Bool {
        guard let cursorApp = findCursorApp() else {
            logger.log("Cursor not running", category: "WindowFocus")
            return false
        }

        let appElement = AXUIElementCreateApplication(cursorApp.processIdentifier)

        guard let windows = getAppWindows(appElement: appElement) else {
            logger.log("Could not get windows (need accessibility permission)", category: "WindowFocus")
            return false
        }

        return focusMatchingWindow(windows: windows, projectName: projectName, appElement: appElement)
    }

    private func getAppWindows(appElement: AXUIElement) -> [AXUIElement]? {
        var windowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef)
        guard result == .success else { return nil }
        return windowsRef as? [AXUIElement]
    }

    private func focusMatchingWindow(
        windows: [AXUIElement],
        projectName: String,
        appElement: AXUIElement
    ) -> Bool {
        var windowNames: [String] = []

        for window in windows {
            var titleRef: CFTypeRef?
            guard AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef) == .success,
                  let title = titleRef as? String
            else { continue }

            windowNames.append(title)
            if title.contains(projectName) {
                AXUIElementPerformAction(window, kAXRaiseAction as CFString)
                AXUIElementSetAttributeValue(appElement, kAXFrontmostAttribute as CFString, true as CFTypeRef)
                logger.log("Focused window: \(title)", category: "WindowFocus")
                return true
            }
        }

        logger.log("Windows found: \(windowNames.joined(separator: ", "))", category: "WindowFocus")
        logger.log("No window matching '\(projectName)'", category: "WindowFocus")
        return false
    }

    private func activateCursorApp() {
        if let cursorApp = findCursorApp() {
            cursorApp.activate(options: [.activateIgnoringOtherApps])
            logger.log("Activated Cursor app", category: "WindowFocus")
        } else {
            logger.log("Cursor app not found, trying to launch...", category: "WindowFocus")
            if let cursorURL = NSWorkspace.shared
                .urlForApplication(withBundleIdentifier: AppConfig.CursorApp.bundleIdentifier)
            {
                NSWorkspace.shared.openApplication(at: cursorURL, configuration: NSWorkspace.OpenConfiguration())
            }
        }
    }

    private func findCursorApp() -> NSRunningApplication? {
        NSWorkspace.shared.runningApplications.first {
            $0.bundleIdentifier == AppConfig.CursorApp.bundleIdentifier ||
                $0.localizedName == AppConfig.CursorApp.appName
        }
    }
}
