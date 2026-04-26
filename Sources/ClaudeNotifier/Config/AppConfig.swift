import Foundation

enum AppConfig {
    static let httpPort: UInt16 = 19847
    static let logFilePath = "/tmp/claudenotifier_debug.log"
    static let notificationCategoryIdentifier = "CLAUDE_NOTIFICATION"
    static let permissionCategoryIdentifier = "CLAUDE_PERMISSION_REQUEST"
    static let showActionIdentifier = "SHOW_ACTION"
    static let allowActionIdentifier = "PERMISSION_ALLOW"
    static let denyActionIdentifier = "PERMISSION_DENY"

    enum IDE {
        enum BundleIdentifier {
            static let cursor = "com.todesktop.230313mzl4w4u92"
            static let vsCode = "com.microsoft.VSCode"
        }

        static let supported: [(bundleId: String, name: String)] = [
            (BundleIdentifier.vsCode, "Visual Studio Code"),
            (BundleIdentifier.cursor, "Cursor")
        ]

        static var overrideBundleIdentifier: String? {
            ProcessInfo.processInfo.environment["CLAUDE_NOTIFIER_APP_BUNDLE_ID"]
        }
    }
}
