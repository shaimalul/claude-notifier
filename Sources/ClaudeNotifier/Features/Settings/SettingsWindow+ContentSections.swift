import SwiftUI

extension SettingsWindow {
    var notificationsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                labelWithInfo(
                    "Title",
                    info: "The bold headline shown in each notification.\n\nAvailable tokens:\n- {project} — the active project name\n- {message} — Claude's message\n- {sessionId} — the Claude session ID"
                )
                TextField("Title template", text: $settingsStore.settings.titleTemplate)
                Text("Tokens: {project}, {message}, {sessionId}")
                    .font(.caption).foregroundColor(.secondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                labelWithInfo(
                    "Body",
                    info: "The secondary line shown below the title in each notification.\n\nAvailable tokens:\n- {project} — the active project name\n- {message} — Claude's message\n- {sessionId} — the Claude session ID"
                )
                TextField("Body template", text: $settingsStore.settings.bodyTemplate)
                Text("Tokens: {project}, {message}, {sessionId}")
                    .font(.caption).foregroundColor(.secondary)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Preview").font(.caption).foregroundColor(.secondary)
                NotificationPreview(
                    title: renderTemplate(settingsStore.settings.titleTemplate),
                    message: renderTemplate(settingsStore.settings.bodyTemplate)
                )
            }
            Button("Reset to Defaults") { resetTemplates() }
                .help("Restore the default title and body templates")
        } header: {
            sectionHeader("Notification Templates", icon: "text.bubble")
        }
    }

    var actionsSection: some View {
        Section {
            Text("Actions appear in notifications. The first action is the primary.")
                .font(.caption).foregroundColor(.secondary)
            ForEach(Array(settingsStore.settings.customActions.enumerated()), id: \.element.id) { index, action in
                actionRow(action: action, index: index)
            }
            if settingsStore.settings.customActions.count < Self.maxActions {
                Button("Add Action") { addAction() }
                    .help("Add a notification action button (max \(Self.maxActions))")
            }
        } header: {
            sectionHeader("Notification Actions", icon: "hand.tap")
        }
    }

    func actionRow(action: CustomAction, index: Int) -> some View {
        HStack {
            TextField("Title", text: Binding(
                get: { action.title },
                set: { updateActionTitle(at: index, to: $0) }
            ))
            .help("Label shown on this action button in the notification")
            Picker("", selection: Binding(
                get: { action.kind },
                set: { updateActionKind(at: index, to: $0) }
            )) {
                ForEach(CustomAction.Kind.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }
            .labelsHidden()
            .frame(width: 160)
            .help("What happens when this action button is tapped")
            Button { removeAction(at: index) } label: { Image(systemName: "minus.circle") }
                .buttonStyle(.plain)
                .disabled(!canRemoveAction(action))
                .help("Remove this action")
        }
    }

    var ideSection: some View {
        Section {
            Picker(selection: $selectedIDEOption) {
                ForEach(IDEOption.allCases) { Text($0.displayName).tag($0) }
            } label: {
                labelWithInfo(
                    "Focus",
                    info: "Which IDE window to bring to the front when you tap a notification.\n\nAuto-detect picks whichever supported IDE is currently running. If both are open, Cursor takes priority."
                )
            }
            .onChange(of: selectedIDEOption) { newValue in
                if newValue != .custom { settingsStore.settings.ideBundleId = newValue.bundleId }
            }
            if selectedIDEOption == .custom {
                VStack(alignment: .leading, spacing: 4) {
                    labelWithInfo(
                        "Bundle ID",
                        info: "The macOS bundle identifier for your IDE.\n\nExamples:\n- Cursor: com.todesktop.230313mzl4w4u92\n- VS Code: com.microsoft.VSCode\n- Zed: dev.zed.Zed\n\nFind it by running: osascript -e 'id of app \"YourApp\"'"
                    )
                    TextField("e.g. com.microsoft.VSCode", text: $settingsStore.settings.ideBundleId)
                }
            }
            if !runningIDEs.isEmpty {
                Text("Running: \(runningIDEs.joined(separator: ", "))")
                    .font(.caption).foregroundColor(.secondary)
            }
        } header: {
            sectionHeader("IDE", icon: "laptopcomputer")
        }
    }

    var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(appVersion).foregroundColor(.secondary)
            }
            Button("Check for Updates...") { UpdateService.shared.checkForUpdates() }
                .help("Check if a newer version of Claude Notifier is available")
            Button("View Logs") {
                NSWorkspace.shared.open(URL(fileURLWithPath: "/tmp/claudenotifier_debug.log"))
            }
            .help("Open the debug log file in the default text editor")
            Button("Reset All Settings", role: .destructive) { showResetConfirmation = true }
                .help("Restore every setting to its factory default")
                .alert("Reset All Settings?", isPresented: $showResetConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Reset", role: .destructive) { SettingsStore.shared.reset() }
                } message: {
                    Text("This will restore all settings to defaults and cannot be undone.")
                }
        } header: {
            sectionHeader("About", icon: "info.circle")
        }
    }
}
