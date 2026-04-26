import Foundation

struct CustomAction: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let kind: Kind

    enum Kind: String, Codable, CaseIterable {
        case showIDE = "show_ide"
        case copyCwd = "copy_cwd"
        case openTerminal = "open_terminal"
        case revealInFinder = "reveal_in_finder"
        case snooze5m = "snooze_5m"
        case snooze15m = "snooze_15m"
        case snooze60m = "snooze_60m"

        var displayName: String {
            switch self {
            case .showIDE: "Show IDE"
            case .copyCwd: "Copy Path"
            case .openTerminal: "Open Terminal"
            case .revealInFinder: "Reveal in Finder"
            case .snooze5m: "Snooze 5 min"
            case .snooze15m: "Snooze 15 min"
            case .snooze60m: "Snooze 1 hour"
            }
        }

        var requiresForeground: Bool {
            self == .showIDE
        }
    }
}
