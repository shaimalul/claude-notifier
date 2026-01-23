import AppKit
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var httpServer: HTTPServer?
    private var notificationDelegate: NotificationDelegate?
    private let logger: LoggerProtocol = Logger.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.log("App starting...", category: "AppDelegate")

        NSApp.setActivationPolicy(.accessory)

        notificationDelegate = NotificationDelegate()
        UNUserNotificationCenter.current().delegate = notificationDelegate
        logger.log("Notification delegate set", category: "AppDelegate")

        setupNotificationCategories()
        logger.log("Categories set up", category: "AppDelegate")

        requestNotificationPermission { [weak self] in
            self?.startHTTPServer()
        }

        WindowFocusHandler.shared.requestAccessibilityPermissions()
        logger.log("App setup complete", category: "AppDelegate")
    }

    func applicationWillTerminate(_ notification: Notification) {
        httpServer?.stop()
    }

    private func requestNotificationPermission(completion: @escaping () -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .provisional]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    self?.logger.log("Notification permission granted", category: "AppDelegate")
                } else {
                    let errorMessage = error?.localizedDescription ?? "unknown"
                    self?.logger.log("Notification permission denied: \(errorMessage)", category: "AppDelegate")
                }
                completion()
            }
        }
    }

    private func setupNotificationCategories() {
        let showAction = UNNotificationAction(
            identifier: AppConfig.showActionIdentifier,
            title: "Show",
            options: [.foreground]
        )

        let category = UNNotificationCategory(
            identifier: AppConfig.notificationCategoryIdentifier,
            actions: [showAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    private func startHTTPServer() {
        httpServer = HTTPServer(port: AppConfig.httpPort) { [weak self] notification in
            self?.logger.log("Received notification for: \(notification.projectName)", category: "AppDelegate")
            NotificationService.shared.sendNotification(notification)
        }
        httpServer?.start()
        logger.log("HTTP Server started on port \(AppConfig.httpPort)", category: "AppDelegate")
    }
}
