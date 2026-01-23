import Foundation

struct ClaudeNotification: Codable, Identifiable, Equatable {
    let id: UUID
    let message: String
    let cwd: String
    let sessionId: String
    let type: NotificationType
    let timestamp: Date
    var isRead: Bool

    enum NotificationType: String, Codable {
        case permissionPrompt = "permission_prompt"
        case idlePrompt = "idle_prompt"
        case elicitationDialog = "elicitation_dialog"
        case unknown

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = NotificationType(rawValue: rawValue) ?? .unknown
        }
    }

    init(message: String, cwd: String, sessionId: String, type: String, timestamp: TimeInterval) {
        self.id = UUID()
        self.message = message
        self.cwd = cwd
        self.sessionId = sessionId
        self.type = NotificationType(rawValue: type) ?? .unknown
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.isRead = false
    }

    var projectName: String {
        URL(fileURLWithPath: cwd).lastPathComponent
    }

    var typeDisplayName: String {
        switch type {
        case .permissionPrompt:
            return "Permission Request"
        case .idlePrompt:
            return "Waiting for Input"
        case .elicitationDialog:
            return "Input Required"
        case .unknown:
            return "Notification"
        }
    }

    var typeIcon: String {
        switch type {
        case .permissionPrompt:
            return "lock.shield"
        case .idlePrompt:
            return "clock"
        case .elicitationDialog:
            return "text.bubble"
        case .unknown:
            return "bell"
        }
    }
}
