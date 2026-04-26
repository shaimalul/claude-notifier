import AppKit
import Foundation
import SwiftUI

struct SettingsWindow: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @State private var showResetConfirmation = false
    @State private var availableSounds: [String] = []
    @State private var selectedIDEOption: IDEOption = .autoDetect
    @State private var runningIDEs: [String] = []

    private static let systemSoundsPath = "/System/Library/Sounds"
    private static let eventTypes: [(key: String, label: String)] = [
        ("permission_prompt", "Permission Request"),
        ("idle_prompt", "Waiting for Input"),
        ("elicitation_dialog", "Input Required"),
        ("unknown", "Other"),
    ]
    private static let sampleProject = "my-app"
    private static let sampleMessage = "Permission requested: Bash"
    private static let sampleSessionId = "abc123"
    private static let maxActions = 3
    private static let showActionId = "SHOW_ACTION"

    var body: some View {
        ScrollView {
            Form {
                generalSection
                soundSection
                notificationsSection
                actionsSection
                ideSection
                aboutSection
            }
            .formStyle(.grouped)
            .padding()
        }
        .frame(width: 520)
        .onAppear {
            loadSounds()
            selectedIDEOption = IDEOption.fromBundleId(settingsStore.settings.ideBundleId)
            refreshRunningIDEs()
        }
    }

    // MARK: - General

    private var generalSection: some View {
        Section("General") {
            Toggle("Launch at Login", isOn: $settingsStore.settings.launchAtLogin)
                .onChange(of: settingsStore.settings.launchAtLogin) { newValue in
                    try? LaunchAtLoginService.shared.setEnabled(newValue)
                }
            Toggle("Start Paused", isOn: $settingsStore.settings.isPaused)
            Toggle("Do Not Disturb", isOn: $settingsStore.settings.dndEnabled)
            if settingsStore.settings.dndEnabled {
                Picker("From", selection: $settingsStore.settings.dndStartHour) {
                    ForEach(0 ..< 24, id: \.self) { Text("\($0):00").tag($0) }
                }
                Picker("Until", selection: $settingsStore.settings.dndEndHour) {
                    ForEach(0 ..< 24, id: \.self) { Text("\($0):00").tag($0) }
                }
            }
            Section("Notify on") {
                ForEach(Self.eventTypes, id: \.key) { event in
                    Toggle(event.label, isOn: Binding(
                        get: { settingsStore.settings.enabledEventTypes.contains(event.key) },
                        set: { _ in toggleEvent(event.key) }
                    ))
                }
            }
        }
    }

    // MARK: - Sound

    private var soundSection: some View {
        Section("Sound") {
            Picker("Sound", selection: $settingsStore.settings.soundPath) {
                Text("None").tag("")
                ForEach(availableSounds, id: \.self) { path in
                    Text(soundDisplayName(path)).tag(path)
                }
            }
            HStack {
                Text("Volume")
                Slider(value: $settingsStore.settings.soundVolume, in: 0...1, step: 0.05)
                Text("\(Int(settingsStore.settings.soundVolume * 100))%")
                    .foregroundColor(.secondary)
                    .frame(width: 36, alignment: .trailing)
                Button("Preview") { previewSound() }
                    .disabled(settingsStore.settings.soundPath.isEmpty)
            }
        }
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        Section("Notification Templates") {
            VStack(alignment: .leading, spacing: 4) {
                TextField("Title", text: $settingsStore.settings.titleTemplate)
                Text("Tokens: {project}, {message}, {sessionId}")
                    .font(.caption).foregroundColor(.secondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                TextField("Body", text: $settingsStore.settings.bodyTemplate)
                Text("Tokens: {project}, {message}, {sessionId}")
                    .font(.caption).foregroundColor(.secondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Preview").font(.caption).foregroundColor(.secondary)
                Text(renderTemplate(settingsStore.settings.titleTemplate)).font(.headline)
                Text(renderTemplate(settingsStore.settings.bodyTemplate))
                    .font(.body).foregroundColor(.secondary)
            }
            Button("Reset to Defaults") { resetTemplates() }
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        Section("Notification Actions") {
            Text("Actions appear in notifications. First action is the primary.")
                .font(.caption).foregroundColor(.secondary)
            ForEach(Array(settingsStore.settings.customActions.enumerated()), id: \.element.id) { index, action in
                actionRow(action: action, index: index)
            }
            if settingsStore.settings.customActions.count < Self.maxActions {
                Button("Add Action") { addAction() }
            }
        }
    }

    private func actionRow(action: CustomAction, index: Int) -> some View {
        HStack {
            TextField("Title", text: Binding(
                get: { action.title },
                set: { updateActionTitle(at: index, to: $0) }
            ))
            Picker("", selection: Binding(
                get: { action.kind },
                set: { updateActionKind(at: index, to: $0) }
            )) {
                ForEach(CustomAction.Kind.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }
            .labelsHidden()
            .frame(width: 160)
            Button { removeAction(at: index) } label: { Image(systemName: "minus.circle") }
                .buttonStyle(.plain)
                .disabled(!canRemoveAction(action))
        }
    }

    // MARK: - IDE

    private var ideSection: some View {
        Section("IDE") {
            Picker("Focus", selection: $selectedIDEOption) {
                ForEach(IDEOption.allCases) { Text($0.displayName).tag($0) }
            }
            .onChange(of: selectedIDEOption) { newValue in
                if newValue != .custom { settingsStore.settings.ideBundleId = newValue.bundleId }
            }
            if selectedIDEOption == .custom {
                TextField("Bundle ID", text: $settingsStore.settings.ideBundleId)
            }
            if !runningIDEs.isEmpty {
                Text("Running: \(runningIDEs.joined(separator: ", "))")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(appVersion).foregroundColor(.secondary)
            }
            Button("Check for Updates...") { UpdateService.shared.checkForUpdates() }
            Button("View Logs") {
                NSWorkspace.shared.open(URL(fileURLWithPath: "/tmp/claudenotifier_debug.log"))
            }
            Button("Reset All Settings", role: .destructive) { showResetConfirmation = true }
                .alert("Reset All Settings?", isPresented: $showResetConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Reset", role: .destructive) { SettingsStore.shared.reset() }
                } message: {
                    Text("This will restore all settings to defaults and cannot be undone.")
                }
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private func soundDisplayName(_ path: String) -> String {
        URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
    }

    private func loadSounds() {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: Self.systemSoundsPath) else { return }
        availableSounds = files.filter { $0.hasSuffix(".aiff") }.sorted()
            .map { "\(Self.systemSoundsPath)/\($0)" }
    }

    private func previewSound() {
        let path = settingsStore.settings.soundPath
        guard !path.isEmpty else { return }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/afplay")
        process.arguments = ["-v", String(settingsStore.settings.soundVolume), path]
        try? process.run()
    }

    private func renderTemplate(_ template: String) -> String {
        template
            .replacingOccurrences(of: "{project}", with: Self.sampleProject)
            .replacingOccurrences(of: "{message}", with: Self.sampleMessage)
            .replacingOccurrences(of: "{sessionId}", with: Self.sampleSessionId)
    }

    private func resetTemplates() {
        settingsStore.settings.titleTemplate = UserSettings.default.titleTemplate
        settingsStore.settings.bodyTemplate = UserSettings.default.bodyTemplate
    }

    private func toggleEvent(_ type: String) {
        var types = settingsStore.settings.enabledEventTypes
        if let i = types.firstIndex(of: type) { types.remove(at: i) } else { types.append(type) }
        settingsStore.settings.enabledEventTypes = types
    }

    private func addAction() {
        var actions = settingsStore.settings.customActions
        guard actions.count < Self.maxActions else { return }
        actions.append(CustomAction(id: UUID().uuidString, title: "New Action", kind: .copyCwd))
        settingsStore.settings.customActions = actions
        NotificationCenter.default.post(name: .settingsActionsDidChange, object: nil)
    }

    private func removeAction(at index: Int) {
        var actions = settingsStore.settings.customActions
        guard index < actions.count, canRemoveAction(actions[index]) else { return }
        actions.remove(at: index)
        settingsStore.settings.customActions = actions
        NotificationCenter.default.post(name: .settingsActionsDidChange, object: nil)
    }

    private func updateActionTitle(at index: Int, to title: String) {
        var actions = settingsStore.settings.customActions
        guard index < actions.count else { return }
        let a = actions[index]
        actions[index] = CustomAction(id: a.id, title: title, kind: a.kind)
        settingsStore.settings.customActions = actions
        NotificationCenter.default.post(name: .settingsActionsDidChange, object: nil)
    }

    private func updateActionKind(at index: Int, to kind: CustomAction.Kind) {
        var actions = settingsStore.settings.customActions
        guard index < actions.count else { return }
        let a = actions[index]
        actions[index] = CustomAction(id: a.id, title: a.title, kind: kind)
        settingsStore.settings.customActions = actions
        NotificationCenter.default.post(name: .settingsActionsDidChange, object: nil)
    }

    private func canRemoveAction(_ action: CustomAction) -> Bool {
        settingsStore.settings.customActions.count > 1 && action.id != Self.showActionId
    }

    private func refreshRunningIDEs() {
        let running = NSWorkspace.shared.runningApplications
        runningIDEs = AppConfig.IDE.supported.compactMap { ide in
            running.contains(where: { $0.bundleIdentifier == ide.bundleId }) ? ide.name : nil
        }
    }

    // MARK: - IDE option enum (local)

    enum IDEOption: String, CaseIterable, Identifiable {
        case autoDetect, cursor, vsCode, custom
        var id: String { rawValue }

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
