@testable import ClaudeNotifier
import XCTest

final class AppConfigTests: XCTestCase {
    func test_httpPort_hasExpectedValue() {
        XCTAssertEqual(AppConfig.httpPort, 19847)
    }

    func test_logFilePath_isNotEmpty() {
        XCTAssertFalse(AppConfig.logFilePath.isEmpty)
        XCTAssertTrue(AppConfig.logFilePath.hasSuffix(".log"))
    }

    func test_soundFilePath_pointsToSystemSound() {
        XCTAssertTrue(AppConfig.soundFilePath.contains("/System/Library/Sounds/"))
    }

    func test_notificationCategoryIdentifier_isNotEmpty() {
        XCTAssertFalse(AppConfig.notificationCategoryIdentifier.isEmpty)
    }

    func test_showActionIdentifier_isNotEmpty() {
        XCTAssertFalse(AppConfig.showActionIdentifier.isEmpty)
    }

    func test_cursorAppBundleIdentifier_isNotEmpty() {
        XCTAssertFalse(AppConfig.CursorApp.bundleIdentifier.isEmpty)
    }

    func test_cursorAppName_isCursor() {
        XCTAssertEqual(AppConfig.CursorApp.appName, "Cursor")
    }
}
