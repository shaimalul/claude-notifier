import Foundation
import AppKit

class WindowFocusHandler {
    static let shared = WindowFocusHandler()
    private let logFile = "/tmp/claudenotifier_debug.log"

    private init() {}

    private func log(_ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logMessage = "[\(timestamp)] \(message)\n"
        NSLog("%@", message)
        if let data = logMessage.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFile) {
                if let handle = FileHandle(forWritingAtPath: logFile) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                FileManager.default.createFile(atPath: logFile, contents: data)
            }
        }
    }

    /// Focus the Cursor window that matches the given project path
    func focusCursorWindow(forProjectPath path: String) {
        log("Attempting to focus Cursor for path: \(path)")

        // ALWAYS activate Cursor app first
        activateCursorApp()

        // Then try to focus specific window
        let projectName = URL(fileURLWithPath: path).lastPathComponent
        if focusWindowUsingAppleScript(projectName: projectName) {
            log("Focused specific window: \(projectName)")
        } else {
            log("Could not focus specific window, but Cursor is activated")
        }
    }

    /// Focus window using Accessibility API directly
    private func focusWindowUsingAppleScript(projectName: String) -> Bool {
        guard let cursorApp = NSWorkspace.shared.runningApplications.first(where: {
            $0.bundleIdentifier == "com.todesktop.230313mzl4w4u92" || $0.localizedName == "Cursor"
        }) else {
            log("Cursor not running")
            return false
        }

        let appElement = AXUIElementCreateApplication(cursorApp.processIdentifier)

        var windowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef)

        guard result == .success, let windows = windowsRef as? [AXUIElement] else {
            log("Could not get windows (need accessibility permission)")
            return false
        }

        var windowNames: [String] = []
        for window in windows {
            var titleRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef) == .success,
               let title = titleRef as? String {
                windowNames.append(title)
                if title.contains(projectName) {
                    // Raise this window
                    AXUIElementPerformAction(window, kAXRaiseAction as CFString)
                    AXUIElementSetAttributeValue(appElement, kAXFrontmostAttribute as CFString, true as CFTypeRef)
                    log("Focused window: \(title)")
                    return true
                }
            }
        }

        log("Windows found: \(windowNames.joined(separator: ", "))")
        log("No window matching '\(projectName)'")
        return false
    }

    /// Activate Cursor app (doesn't require accessibility permissions)
    private func activateCursorApp() {
        let runningApps = NSWorkspace.shared.runningApplications
        if let cursorApp = runningApps.first(where: {
            $0.bundleIdentifier == "com.todesktop.230313mzl4w4u92" ||
            $0.localizedName == "Cursor"
        }) {
            cursorApp.activate(options: [.activateIgnoringOtherApps])
            log("Activated Cursor app")
        } else {
            log("Cursor app not found, trying to launch...")
            NSWorkspace.shared.launchApplication("Cursor")
        }
    }

    /// Check if accessibility permissions are granted
    func checkAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    /// Request accessibility permissions
    func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }
}
