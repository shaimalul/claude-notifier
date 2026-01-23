import Foundation
import UserNotifications

final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()

    private let logger: LoggerProtocol

    init(logger: LoggerProtocol = Logger.shared) {
        self.logger = logger
    }

    func sendNotification(_ notification: ClaudeNotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.projectName
        content.body = notification.message
        content.sound = UNNotificationSound.default
        content.userInfo = ["cwd": notification.cwd]
        content.categoryIdentifier = AppConfig.notificationCategoryIdentifier

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

        playSound()
    }

    private func playSound() {
        guard FileManager.default.fileExists(atPath: AppConfig.soundFilePath) else {
            logger.log("Sound file not found: \(AppConfig.soundFilePath)", category: "Notification")
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/afplay")
        process.arguments = ["-v", AppConfig.soundVolume, AppConfig.soundFilePath]

        do {
            try process.run()
        } catch {
            logger.log("Failed to play sound: \(error.localizedDescription)", category: "Notification")
        }
    }
}
