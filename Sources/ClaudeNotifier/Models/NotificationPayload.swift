import Foundation

struct NotificationPayload: Codable {
    let message: String
    let cwd: String
    let sessionId: String
    let type: String
    let timestamp: TimeInterval
    let ideBundleId: String?
    let responsePipe: String?

    func toClaudeNotification() -> ClaudeNotification {
        ClaudeNotification(
            message: message,
            cwd: cwd,
            sessionId: sessionId,
            type: type,
            timestamp: timestamp,
            ideBundleId: ideBundleId,
            responsePipe: responsePipe
        )
    }
}
