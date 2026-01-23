import Foundation
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let logger: LoggerProtocol
    private let windowFocusHandler: WindowFocusProtocol

    init(
        logger: LoggerProtocol = Logger.shared,
        windowFocusHandler: WindowFocusProtocol = WindowFocusHandler.shared
    ) {
        self.logger = logger
        self.windowFocusHandler = windowFocusHandler
        super.init()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        logger.log("didReceive called!", category: "NotifDelegate")
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier

        logger.log("Action: \(actionIdentifier)", category: "NotifDelegate")
        logger.log("UserInfo: \(userInfo)", category: "NotifDelegate")

        if let cwd = userInfo["cwd"] as? String {
            let shouldFocus = actionIdentifier == UNNotificationDefaultActionIdentifier ||
                             actionIdentifier == AppConfig.showActionIdentifier

            if shouldFocus {
                logger.log("Focusing Cursor for: \(cwd)", category: "NotifDelegate")
                DispatchQueue.main.async { [weak self] in
                    self?.windowFocusHandler.focusCursorWindow(forProjectPath: cwd)
                }
            }
        } else {
            logger.log("No cwd in userInfo!", category: "NotifDelegate")
        }

        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        logger.log("willPresent called - notification arriving", category: "NotifDelegate")
        completionHandler([.banner, .sound])
    }
}
