import Foundation

struct UserSettings: Codable, Equatable {
    var soundPath: String
    var soundVolume: Double
    var titleTemplate: String
    var bodyTemplate: String
    var customActions: [CustomAction]
    var ideBundleId: String
    var isPaused: Bool
    var launchAtLogin: Bool
    var dndEnabled: Bool
    var dndStartHour: Int
    var dndEndHour: Int
    var enabledEventTypes: [String]

    static let `default` = UserSettings(
        soundPath: "/System/Library/Sounds/Glass.aiff",
        soundVolume: 0.5,
        titleTemplate: "{project}",
        bodyTemplate: "{message}",
        customActions: [
            CustomAction(id: "SHOW_ACTION", title: "Open in IDE", kind: .showIDE),
            CustomAction(id: "COPY_ACTION", title: "Copy Path", kind: .copyCwd)
        ],
        ideBundleId: "",
        isPaused: false,
        launchAtLogin: false,
        dndEnabled: false,
        dndStartHour: 22,
        dndEndHour: 8,
        enabledEventTypes: ["permission_prompt", "idle_prompt", "elicitation_dialog", "unknown"]
    )

    func isCurrentlyDND(atHour hour: Int = Calendar.current.component(.hour, from: Date())) -> Bool {
        guard dndEnabled else { return false }
        if dndStartHour <= dndEndHour {
            return hour >= dndStartHour && hour < dndEndHour
        }
        return hour >= dndStartHour || hour < dndEndHour
    }
}
