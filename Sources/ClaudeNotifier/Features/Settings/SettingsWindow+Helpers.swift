import AppKit
import SwiftUI

extension SettingsWindow {
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .textCase(nil)
    }

    func labelWithInfo(_ title: String, info: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            InfoButton(text: info)
        }
    }

    func soundDisplayName(_ path: String) -> String {
        URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
    }

    func loadSounds() {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: Self.systemSoundsPath) else { return }
        availableSounds = files.filter { $0.hasSuffix(".aiff") }.sorted()
            .map { "\(Self.systemSoundsPath)/\($0)" }
    }

    func previewSound() {
        let path = settingsStore.settings.soundPath
        guard !path.isEmpty else { return }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/afplay")
        process.arguments = ["-v", String(settingsStore.settings.soundVolume), path]
        try? process.run()
    }

    func renderTemplate(_ template: String) -> String {
        template
            .replacingOccurrences(of: "{project}", with: Self.sampleProject)
            .replacingOccurrences(of: "{message}", with: Self.sampleMessage)
            .replacingOccurrences(of: "{sessionId}", with: Self.sampleSessionId)
    }

    func resetTemplates() {
        settingsStore.settings.titleTemplate = UserSettings.default.titleTemplate
        settingsStore.settings.bodyTemplate = UserSettings.default.bodyTemplate
    }

    func toggleEvent(_ type: String) {
        var types = settingsStore.settings.enabledEventTypes
        if let i = types.firstIndex(of: type) { types.remove(at: i) } else { types.append(type) }
        settingsStore.settings.enabledEventTypes = types
    }

    func addAction() {
        var actions = settingsStore.settings.customActions
        guard actions.count < Self.maxActions else { return }
        actions.append(CustomAction(id: UUID().uuidString, title: "New Action", kind: .copyCwd))
        settingsStore.settings.customActions = actions
        NotificationCenter.default.post(name: .settingsActionsDidChange, object: nil)
    }

    func removeAction(at index: Int) {
        var actions = settingsStore.settings.customActions
        guard index < actions.count, canRemoveAction(actions[index]) else { return }
        actions.remove(at: index)
        settingsStore.settings.customActions = actions
        NotificationCenter.default.post(name: .settingsActionsDidChange, object: nil)
    }

    func updateActionTitle(at index: Int, to title: String) {
        var actions = settingsStore.settings.customActions
        guard index < actions.count else { return }
        let a = actions[index]
        actions[index] = CustomAction(id: a.id, title: title, kind: a.kind)
        settingsStore.settings.customActions = actions
        NotificationCenter.default.post(name: .settingsActionsDidChange, object: nil)
    }

    func updateActionKind(at index: Int, to kind: CustomAction.Kind) {
        var actions = settingsStore.settings.customActions
        guard index < actions.count else { return }
        let a = actions[index]
        actions[index] = CustomAction(id: a.id, title: a.title, kind: kind)
        settingsStore.settings.customActions = actions
        NotificationCenter.default.post(name: .settingsActionsDidChange, object: nil)
    }

    func canRemoveAction(_ action: CustomAction) -> Bool {
        settingsStore.settings.customActions.count > 1 && action.id != Self.showActionId
    }

    func refreshRunningIDEs() {
        let running = NSWorkspace.shared.runningApplications
        runningIDEs = AppConfig.IDE.supported.compactMap { ide in
            running.contains(where: { $0.bundleIdentifier == ide.bundleId }) ? ide.name : nil
        }
    }

    enum IDEOption: String, CaseIterable, Identifiable {
        case autoDetect, cursor, vsCode, custom
        var id: String {
            rawValue
        }

        var displayName: String {
            switch self {
            case .autoDetect: "Auto-detect"
            case .cursor: "Cursor"
            case .vsCode: "Visual Studio Code"
            case .custom: "Custom Bundle ID"
            }
        }

        var bundleId: String {
            switch self {
            case .autoDetect: ""
            case .cursor: AppConfig.IDE.BundleIdentifier.cursor
            case .vsCode: AppConfig.IDE.BundleIdentifier.vsCode
            case .custom: ""
            }
        }

        static func fromBundleId(_ id: String) -> IDEOption {
            if id.isEmpty { return .autoDetect }
            if id == AppConfig.IDE.BundleIdentifier.cursor { return .cursor }
            if id == AppConfig.IDE.BundleIdentifier.vsCode { return .vsCode }
            return .custom
        }
    }
}
