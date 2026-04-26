import AppKit
import Foundation

final class ActionDispatcher {
    static let shared = ActionDispatcher()

    private var snoozedUntil: Date?

    var isSnoozed: Bool {
        guard let snoozedUntil else { return false }
        return snoozedUntil > Date()
    }

    func dispatch(actionIdentifier: String, cwd: String, ideBundleId: String?, responsePipe: String? = nil) {
        // Permission request actions — write response to the named pipe
        if actionIdentifier == AppConfig.allowActionIdentifier {
            writeResponse("allow", to: responsePipe)
            return
        }
        if actionIdentifier == AppConfig.denyActionIdentifier {
            writeResponse("deny", to: responsePipe)
            return
        }

        let actions = SettingsStore.shared.settings.customActions
        let action = actions.first { $0.id == actionIdentifier }
        let kind = action?.kind ?? .showIDE

        switch kind {
        case .showIDE:
            WindowFocusHandler.shared.focusIDEWindow(forProjectPath: cwd, ideBundleId: ideBundleId)
        case .copyCwd:
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(cwd, forType: .string)
        case .openTerminal:
            openTerminalAt(path: cwd)
        case .revealInFinder:
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: cwd)
        case .snooze5m:
            activateSnooze(minutes: 5)
        case .snooze15m:
            activateSnooze(minutes: 15)
        case .snooze60m:
            activateSnooze(minutes: 60)
        }
    }

    func activateSnooze(minutes: Int) {
        snoozedUntil = Date().addingTimeInterval(TimeInterval(minutes * 60))
    }

    func clearSnooze() {
        snoozedUntil = nil
    }

    private func writeResponse(_ response: String, to pipe: String?) {
        guard let pipe else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            let data = (response + "\n").data(using: .utf8)!
            FileManager.default.createFile(atPath: pipe, contents: nil)
            if let handle = FileHandle(forWritingAtPath: pipe) {
                handle.write(data)
                handle.closeFile()
            }
        }
    }

    private func openTerminalAt(path: String) {
        let escapedPath = path.replacingOccurrences(of: "'", with: "'\\''")
        let script = "tell application \"Terminal\" to do script \"cd '\(escapedPath)'\""
        guard let appleScript = NSAppleScript(source: script) else { return }
        var error: NSDictionary?
        appleScript.executeAndReturnError(&error)
    }
}
