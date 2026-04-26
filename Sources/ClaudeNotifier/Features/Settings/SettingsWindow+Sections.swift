import SwiftUI

extension SettingsWindow {
    var generalSection: some View {
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

    var soundSection: some View {
        Section("Sound") {
            Picker("Sound", selection: $settingsStore.settings.soundPath) {
                Text("None").tag("")
                ForEach(availableSounds, id: \.self) { path in
                    Text(soundDisplayName(path)).tag(path)
                }
            }
            HStack {
                Text("Volume")
                Slider(value: $settingsStore.settings.soundVolume, in: 0 ... 1, step: 0.05)
                Text("\(Int(settingsStore.settings.soundVolume * 100))%")
                    .foregroundColor(.secondary)
                    .frame(width: 36, alignment: .trailing)
                Button("Preview") { previewSound() }
                    .disabled(settingsStore.settings.soundPath.isEmpty)
            }
        }
    }

    var notificationsSection: some View {
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

    var actionsSection: some View {
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

    func actionRow(action: CustomAction, index: Int) -> some View {
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

    var ideSection: some View {
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

    var aboutSection: some View {
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
}
