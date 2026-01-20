import SwiftUI
import AppKit
import UserNotifications

private let logFile = "/tmp/claudenotifier_debug.log"

private func log(_ message: String) {
    let timestamp = ISO8601DateFormatter().string(from: Date())
    let logMessage = "[\(timestamp)] [AppDelegate] \(message)\n"
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

@main
struct ClaudeNotifierApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var httpServer: HTTPServer?
    private var notificationDelegate: NotificationDelegate?

    func applicationDidFinishLaunching(_ notification: Notification) {
        log("App starting...")

        // Hide dock icon (background app)
        NSApp.setActivationPolicy(.accessory)

        // Set up notification delegate for click handling
        notificationDelegate = NotificationDelegate()
        UNUserNotificationCenter.current().delegate = notificationDelegate
        log("Notification delegate set")

        // Setup notification action buttons
        setupNotificationCategories()
        log("Categories set up")

        // Request notification permission, then start server
        requestNotificationPermission { [weak self] in
            self?.startHTTPServer()
        }

        // Request accessibility permission (for window focus)
        WindowFocusHandler.shared.requestAccessibilityPermissions()
        log("App setup complete")
    }

    func applicationWillTerminate(_ notification: Notification) {
        httpServer?.stop()
    }

    private func requestNotificationPermission(completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .provisional]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    log("Notification permission granted")
                } else {
                    log("Notification permission denied: \(error?.localizedDescription ?? "unknown")")
                }
                completion()
            }
        }
    }

    private func setupNotificationCategories() {
        let showAction = UNNotificationAction(
            identifier: "SHOW_ACTION",
            title: "Show",
            options: [.foreground]
        )

        let category = UNNotificationCategory(
            identifier: "CLAUDE_NOTIFICATION",
            actions: [showAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    private func startHTTPServer() {
        httpServer = HTTPServer(port: 19847) { notification in
            log("Received notification request for: \(notification.projectName)")
            NotificationManager.shared.sendNotification(notification)
        }
        httpServer?.start()
        log("HTTP Server started on port 19847")
    }
}
