import AppKit
import Foundation

private let kAXTrustedKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String

final class WindowFocusHandler: WindowFocusProtocol {
    static let shared = WindowFocusHandler()

    let logger: LoggerProtocol

    init(logger: LoggerProtocol = Logger.shared) {
        self.logger = logger
    }

    func focusIDEWindow(forProjectPath path: String, ideBundleId: String?) {
        guard let app = resolveRunningIDE(hintBundleId: ideBundleId, forPath: path) else {
            logger.log("No supported IDE is running", category: "WindowFocus")
            return
        }

        let bundleId = app.bundleIdentifier ?? ""
        let projectName = URL(fileURLWithPath: path).lastPathComponent
        logger.log("Focusing \(app.localizedName ?? "IDE") on project: \(projectName)", category: "WindowFocus")

        // Primary: use the IDE CLI to jump directly to the right folder window
        if openViaCLI(app: app, path: path) {
            logger.log("Opened via CLI", category: "WindowFocus")
            return
        }

        // Fallback: activate app then try AX window matching
        activateAndFocus(app: app, projectName: projectName)
    }

    func checkAccessibilityPermissions() -> Bool {
        AXIsProcessTrusted()
    }

    func requestAccessibilityPermissions() {
        guard !AXIsProcessTrusted() else { return }
        _ = AXIsProcessTrustedWithOptions([kAXTrustedKey: true] as CFDictionary)
    }

    // MARK: - CLI approach (no accessibility required)

    private func openViaCLI(app: NSRunningApplication, path: String) -> Bool {
        guard let cliPath = resolveCLI(for: app) else { return false }
        logger.log("Using CLI: \(cliPath)", category: "WindowFocus")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: cliPath)
        process.arguments = ["--reuse-window", path]
        do {
            try process.run()
            return true
        } catch {
            logger.log("CLI launch failed: \(error)", category: "WindowFocus")
            return false
        }
    }

    private func resolveCLI(for app: NSRunningApplication) -> String? {
        guard let bundleURL = app.bundleURL else { return nil }
        let binDir = bundleURL.appendingPathComponent("Contents/Resources/app/bin")
        for name in ["code", "cursor"] {
            let path = binDir.appendingPathComponent(name).path
            if FileManager.default.isExecutableFile(atPath: path) {
                return path
            }
        }
        return nil
    }

    // MARK: - Activate + AX fallback

    private func activateAndFocus(app: NSRunningApplication, projectName: String) {
        guard let url = app.bundleURL else {
            app.activate(options: [.activateIgnoringOtherApps])
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = true

        NSWorkspace.shared.openApplication(at: url, configuration: config) { [weak self] _, error in
            if let error {
                self?.logger.log("openApplication error: \(error)", category: "WindowFocus")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                _ = self?.focusWindowUsingAccessibility(projectName: projectName, runningApp: app)
            }
        }
    }

    // MARK: - IDE resolution

    private func resolveRunningIDE(hintBundleId: String?, forPath path: String) -> NSRunningApplication? {
        if let override = AppConfig.IDE.overrideBundleIdentifier,
           let app = findRunningApp(bundleId: override) { return app }

        if let hint = hintBundleId,
           let app = findRunningApp(bundleId: hint) { return app }

        let projectName = URL(fileURLWithPath: path).lastPathComponent
        for (bundleId, _) in AppConfig.IDE.supported {
            guard let app = findRunningApp(bundleId: bundleId) else { continue }
            if ideHasWindowForProject(app: app, projectName: projectName) { return app }
        }

        for (bundleId, _) in AppConfig.IDE.supported {
            if let app = findRunningApp(bundleId: bundleId) { return app }
        }
        return nil
    }

    private func findRunningApp(bundleId: String) -> NSRunningApplication? {
        NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier == bundleId }
    }

    private func ideHasWindowForProject(app: NSRunningApplication, projectName: String) -> Bool {
        let el = AXUIElementCreateApplication(app.processIdentifier)
        guard let windows = axWindows(of: el) else { return false }
        return windows.contains { axTitle($0)?.contains(projectName) == true }
    }
}
