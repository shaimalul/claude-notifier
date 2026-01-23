import Foundation

enum AppConfig {
    static let httpPort: UInt16 = 19847
    static let logFilePath = "/tmp/claudenotifier_debug.log"
    static let soundFilePath = "/System/Library/Sounds/Glass.aiff"
    static let soundVolume = "0.5"
    static let notificationCategoryIdentifier = "CLAUDE_NOTIFICATION"
    static let showActionIdentifier = "SHOW_ACTION"

    enum CursorApp {
        static let bundleIdentifier = "com.todesktop.230313mzl4w4u92"
        static let appName = "Cursor"
    }
}
