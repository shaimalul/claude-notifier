import AppKit
import Foundation

extension WindowFocusHandler {
    func focusWindowUsingAccessibility(projectName: String, runningApp: NSRunningApplication) -> Bool {
        let el = AXUIElementCreateApplication(runningApp.processIdentifier)
        guard let windows = axWindows(of: el) else {
            logger.log("AX unavailable - accessibility permission not granted", category: "WindowFocus")
            return false
        }
        for window in windows {
            guard let title = axTitle(window), title.contains(projectName) else { continue }
            AXUIElementPerformAction(window, kAXRaiseAction as CFString)
            AXUIElementSetAttributeValue(el, kAXFrontmostAttribute as CFString, true as CFTypeRef)
            logger.log("AX raised window: \(title)", category: "WindowFocus")
            return true
        }
        logger.log("No AX window matched '\(projectName)'", category: "WindowFocus")
        return false
    }

    func axWindows(of element: AXUIElement) -> [AXUIElement]? {
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXWindowsAttribute as CFString, &ref) == .success
        else { return nil }
        return ref as? [AXUIElement]
    }

    func axTitle(_ element: AXUIElement) -> String? {
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &ref) == .success
        else { return nil }
        return ref as? String
    }
}
