import Foundation

struct ClaudeNotification: Codable, Identifiable, Equatable {
    let id: UUID
    let message: String
    let cwd: String
    let sessionId: String
    let type: NotificationType
    let timestamp: Date
    let ideBundleId: String?
    let responsePipe: String?
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

    init(message: String, cwd: String, sessionId: String, type: String, timestamp: TimeInterval, ideBundleId: String? = nil, responsePipe: String? = nil) {
        self.id = UUID()
        self.message = message
        self.cwd = cwd
        self.sessionId = sessionId
        self.type = NotificationType(rawValue: type) ?? .unknown
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.ideBundleId = ideBundleId
        self.responsePipe = responsePipe
        self.isRead = false
    }

    var projectName: String {
        URL(fileURLWithPath: cwd).lastPathComponent
    }

    var typeDisplayName: String {
        switch type {
        case .permissionPrompt:
            "Permission Request"
        case .idlePrompt:
            "Waiting for Input"
        case .elicitationDialog:
            "Input Required"
        case .unknown:
            "Notification"
        }
    }

    var typeIcon: String {
        switch type {
        case .permissionPrompt:
            "lock.shield"
        case .idlePrompt:
            "clock"
        case .elicitationDialog:
            "text.bubble"
        case .unknown:
            "bell"
        }
    }
}
