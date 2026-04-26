import Foundation
import UserNotifications

final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()

    private let logger: LoggerProtocol

    init(logger: LoggerProtocol = Logger.shared) {
        self.logger = logger
    }

    func sendNotification(_ notification: ClaudeNotification) {
        let settings = SettingsStore.shared.settings

        guard settings.enabledEventTypes.contains(notification.type.rawValue) else {
            logger.log("Event type '\(notification.type.rawValue)' suppressed", category: "Notification")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = render(template: settings.titleTemplate, notification: notification)
        content.body = render(template: settings.bodyTemplate, notification: notification)
        content.sound = UNNotificationSound.default
        let isPermissionRequest = notification.responsePipe != nil
        content.categoryIdentifier = isPermissionRequest
            ? AppConfig.permissionCategoryIdentifier
            : AppConfig.notificationCategoryIdentifier

        var userInfo: [String: Any] = ["cwd": notification.cwd]
        if let ideBundleId = notification.ideBundleId { userInfo["ideBundleId"] = ideBundleId }
        if let pipe = notification.responsePipe { userInfo["responsePipe"] = pipe }
        content.userInfo = userInfo

        let request = UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error {
                self?.logger.log("Notification error: \(error)", category: "Notification")
            }
        }

        if !settings.soundPath.isEmpty {
            playSound(path: settings.soundPath, volume: settings.soundVolume)
        }
    }

    private func render(template: String, notification: ClaudeNotification) -> String {
        template
            .replacingOccurrences(of: "{project}", with: notification.projectName)
            .replacingOccurrences(of: "{message}", with: notification.message)
            .replacingOccurrences(of: "{sessionId}", with: notification.sessionId)
    }

    private func playSound(path: String, volume: Double) {
        guard FileManager.default.fileExists(atPath: path) else {
            logger.log("Sound file not found: \(path)", category: "Notification")
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/afplay")
        process.arguments = ["-v", String(volume), path]

        do {
            try process.run()
        } catch {
            logger.log("Failed to play sound: \(error.localizedDescription)", category: "Notification")
        }
    }
}
