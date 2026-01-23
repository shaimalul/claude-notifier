import Foundation

enum AppConfig {
    static let httpPort: UInt16 = 19847
    static let logFilePath = "/tmp/claudenotifier_debug.log"
    static let soundFilePath = "/System/Library/Sounds/Glass.aiff"
    static let soundVolume = "0.5"
    static let notificationCategoryIdentifier = "CLAUDE_NOTIFICATION"
    static let showActionIdentifier = "SHOW_ACTION"

    enum CursorApp {
        // Configurable via environment variable for custom IDE support
        static var bundleIdentifier: String {
            ProcessInfo.processInfo.environment["CLAUDE_NOTIFIER_APP_BUNDLE_ID"]
                ?? "com.todesktop.230313mzl4w4u92"
        }

        static var appName: String {
            ProcessInfo.processInfo.environment["CLAUDE_NOTIFIER_APP_NAME"]
                ?? "Cursor"
        }
    }
}
