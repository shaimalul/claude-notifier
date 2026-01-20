import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func sendNotification(_ notification: ClaudeNotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.projectName
        content.body = notification.message
        content.sound = UNNotificationSound.default
        content.userInfo = ["cwd": notification.cwd]
        content.categoryIdentifier = "CLAUDE_NOTIFICATION"

        let request = UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }

        // Play sound for reliability
        self.playSound()
    }

    private func playSound() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/afplay")
        process.arguments = ["-v", "0.5", "/System/Library/Sounds/Glass.aiff"]
        try? process.run()
    }
}
