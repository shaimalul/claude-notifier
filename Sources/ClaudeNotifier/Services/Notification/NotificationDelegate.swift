import Foundation
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let logger: LoggerProtocol

    init(logger: LoggerProtocol = Logger.shared) {
        self.logger = logger
        super.init()
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        logger.log("didReceive called!", category: "NotifDelegate")
        let userInfo = response.notification.request.content.userInfo
        let rawIdentifier = response.actionIdentifier

        logger.log("Action: \(rawIdentifier)", category: "NotifDelegate")

        guard let cwd = userInfo["cwd"] as? String else {
            logger.log("No cwd in userInfo!", category: "NotifDelegate")
            completionHandler()
            return
        }

        let actionIdentifier = rawIdentifier == UNNotificationDefaultActionIdentifier
            ? AppConfig.showActionIdentifier
            : rawIdentifier
        let ideBundleId = userInfo["ideBundleId"] as? String
        let responsePipe = userInfo["responsePipe"] as? String

        DispatchQueue.main.async {
            ActionDispatcher.shared.dispatch(
                actionIdentifier: actionIdentifier,
                cwd: cwd,
                ideBundleId: ideBundleId,
                responsePipe: responsePipe
            )
        }

        completionHandler()
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        logger.log("willPresent called - notification arriving", category: "NotifDelegate")
        completionHandler([.banner, .sound])
    }
}
