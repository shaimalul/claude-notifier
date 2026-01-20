import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let logFile = "/tmp/claudenotifier_debug.log"

    private func log(_ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logMessage = "[\(timestamp)] [NotifDelegate] \(message)\n"
        NSLog("%@", message)
        if let data = logMessage.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFile) {
                if let handle = FileHandle(forWritingAtPath: logFile) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                FileManager.default.createFile(atPath: logFile, contents: data)
            }
        }
    }

    /// Called when user clicks on a notification or action button
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        log("didReceive called!")
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier

        log("Action: \(actionIdentifier)")
        log("UserInfo: \(userInfo)")

        // Extract the project path and focus the correct Cursor window
        if let cwd = userInfo["cwd"] as? String {
            // Handle both default tap and "Show" button
            if actionIdentifier == UNNotificationDefaultActionIdentifier ||
               actionIdentifier == "SHOW_ACTION" {
                log("Focusing Cursor for: \(cwd)")
                DispatchQueue.main.async {
                    WindowFocusHandler.shared.focusCursorWindow(forProjectPath: cwd)
                }
            }
        } else {
            log("No cwd in userInfo!")
        }

        completionHandler()
    }

    /// Called when notification arrives while app is in foreground
    /// We still want to show the banner and play sound
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        log("willPresent called - notification arriving")
        completionHandler([.banner, .sound])
    }
}
