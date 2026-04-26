import AppKit
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var httpServer: HTTPServer?
    private var notificationDelegate: NotificationDelegate?
    private let logger: LoggerProtocol = Logger.shared
    private var settingsObserver: Any?

    func applicationWillFinishLaunching(_: Notification) {
        // Set accessory policy immediately — before the run loop ticks — so the
        // app never appears in the Dock, even briefly on notification-triggered relaunches.
        NSApp.setActivationPolicy(.accessory)

        // Notification delegate must also be set here for relaunched-by-click apps.
        notificationDelegate = NotificationDelegate()
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    func applicationDidFinishLaunching(_: Notification) {
        rebuildNotificationCategories()

        settingsObserver = NotificationCenter.default.addObserver(
            forName: .settingsActionsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.rebuildNotificationCategories() }

        requestNotificationPermission { [weak self] in
            self?.startHTTPServer()
        }

        WindowFocusHandler.shared.requestAccessibilityPermissions()

        OnboardingCoordinator.shared.presentIfNeeded()
    }

    func applicationWillTerminate(_: Notification) {
        httpServer?.stop()
        if let obs = settingsObserver { NotificationCenter.default.removeObserver(obs) }
    }

    func rebuildNotificationCategories() {
        let customActions = SettingsStore.shared.settings.customActions.map { action in
            UNNotificationAction(
                identifier: action.id,
                title: action.title,
                options: action.kind.requiresForeground ? [.foreground] : []
            )
        }
        let notificationCategory = UNNotificationCategory(
            identifier: AppConfig.notificationCategoryIdentifier,
            actions: customActions,
            intentIdentifiers: [],
            options: []
        )

        let permissionCategory = UNNotificationCategory(
            identifier: AppConfig.permissionCategoryIdentifier,
            actions: [
                UNNotificationAction(identifier: AppConfig.allowActionIdentifier, title: "Allow", options: []),
                UNNotificationAction(
                    identifier: AppConfig.denyActionIdentifier,
                    title: "Deny",
                    options: [.destructive]
                )
            ],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([notificationCategory, permissionCategory])
    }

    private func requestNotificationPermission(completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert,
            .sound,
            .provisional
        ]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if !granted {
                    self?.logger.log(
                        "Notification permission denied: \(error?.localizedDescription ?? "unknown")",
                        category: "AppDelegate"
                    )
                }
                completion()
            }
        }
    }

    private func startHTTPServer() {
        httpServer = HTTPServer(port: AppConfig.httpPort) { [weak self] notification in
            NotificationHistory.shared.add(notification)
            self?.logger.log("Received notification for: \(notification.projectName)", category: "AppDelegate")
            NotificationService.shared.sendNotification(notification)
        }
        httpServer?.start()
    }
}
