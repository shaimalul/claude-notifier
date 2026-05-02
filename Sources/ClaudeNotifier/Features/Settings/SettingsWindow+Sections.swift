import SwiftUI

extension SettingsWindow {
    var generalSection: some View {
        Section {
            Toggle(isOn: $settingsStore.settings.launchAtLogin) {
                labelWithInfo(
                    "Launch at Login",
                    info: "Automatically starts Claude Notifier when you log in. You won't miss any notifications after a reboot."
                )
            }
            .onChange(of: settingsStore.settings.launchAtLogin) { newValue in
                try? LaunchAtLoginService.shared.setEnabled(newValue)
            }

            Toggle(isOn: $settingsStore.settings.isPaused) {
                labelWithInfo(
                    "Start Paused",
                    info: "Launches without showing any notifications. Resume anytime from the menu bar icon. Useful when you want to start the app without being interrupted right away."
                )
            }

            Toggle(isOn: $settingsStore.settings.dndEnabled) {
                labelWithInfo(
                    "Do Not Disturb",
                    info: "Silences all notifications during the quiet hours you set below. Example: set 22:00–08:00 to mute notifications overnight."
                )
            }

            if settingsStore.settings.dndEnabled {
                Picker("From", selection: $settingsStore.settings.dndStartHour) {
                    ForEach(0 ..< 24, id: \.self) { Text("\($0):00").tag($0) }
                }
                Picker("Until", selection: $settingsStore.settings.dndEndHour) {
                    ForEach(0 ..< 24, id: \.self) { Text("\($0):00").tag($0) }
                }
            }

            Section {
                ForEach(Self.eventTypes, id: \.key) { event in
                    Toggle(isOn: Binding(
                        get: { settingsStore.settings.enabledEventTypes.contains(event.key) },
                        set: { _ in toggleEvent(event.key) }
                    )) {
                        labelWithInfo(event.label, info: eventTypeInfo(event.key))
                    }
                }
            } header: {
                Text("Notify on")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(nil)
            }
        } header: {
            sectionHeader("General", icon: "gearshape")
        }
    }

    var soundSection: some View {
        Section {
            Picker(selection: $settingsStore.settings.soundPath) {
                Text("None").tag("")
                ForEach(availableSounds, id: \.self) { path in
                    Text(soundDisplayName(path)).tag(path)
                }
            } label: {
                labelWithInfo(
                    "Sound",
                    info: "The system sound played alongside each notification. Choose None for silent notifications."
                )
            }

            HStack {
                labelWithInfo(
                    "Volume",
                    info: "Controls how loud the notification sound plays. This is independent of your system volume."
                )
                Slider(value: $settingsStore.settings.soundVolume, in: 0 ... 1, step: 0.05)
                Text("\(Int(settingsStore.settings.soundVolume * 100))%")
                    .foregroundColor(.secondary)
                    .frame(width: 36, alignment: .trailing)
                Button("Preview") { previewSound() }
                    .disabled(settingsStore.settings.soundPath.isEmpty)
            }
        } header: {
            sectionHeader("Sound", icon: "speaker.wave.2")
        }
    }

    func eventTypeInfo(_ key: String) -> String {
        switch key {
        case "permission_prompt":
            "Claude is asking to run a potentially sensitive command and needs your approval.\n\nExample: \"Allow Bash to run npm install?\""
        case "idle_prompt":
            "Claude has finished its current task and is idle, waiting for your next message."
        case "elicitation_dialog":
            "Claude opened an interactive form that requires structured input from you before it can continue.\n\nExample: filling in configuration values."
        default:
            "Any Claude event that doesn't fit the categories above."
        }
    }
}
