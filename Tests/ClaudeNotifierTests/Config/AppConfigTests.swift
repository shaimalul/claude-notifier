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

    func test_notificationCategoryIdentifier_isNotEmpty() {
        XCTAssertFalse(AppConfig.notificationCategoryIdentifier.isEmpty)
    }

    func test_showActionIdentifier_isNotEmpty() {
        XCTAssertFalse(AppConfig.showActionIdentifier.isEmpty)
    }

    func test_cursorBundleIdentifier_isNotEmpty() {
        XCTAssertFalse(AppConfig.IDE.BundleIdentifier.cursor.isEmpty)
    }

    func test_vsCodeBundleIdentifier_isNotEmpty() {
        XCTAssertFalse(AppConfig.IDE.BundleIdentifier.vsCode.isEmpty)
    }

    func test_supportedIDEs_containsCursorAndVSCode() {
        let bundleIds = AppConfig.IDE.supported.map(\.bundleId)
        XCTAssertTrue(bundleIds.contains(AppConfig.IDE.BundleIdentifier.cursor))
        XCTAssertTrue(bundleIds.contains(AppConfig.IDE.BundleIdentifier.vsCode))
    }

    func test_supportedIDEs_haveNonEmptyNames() {
        for ide in AppConfig.IDE.supported {
            XCTAssertFalse(ide.name.isEmpty)
        }
    }
}
