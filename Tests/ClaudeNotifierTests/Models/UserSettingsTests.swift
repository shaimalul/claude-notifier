@testable import ClaudeNotifier
import XCTest

final class UserSettingsTests: XCTestCase {
    // MARK: - DND disabled

    func test_isCurrentlyDND_whenDisabled_returnsFalse() {
        var settings = UserSettings.default
        settings.dndEnabled = false
        XCTAssertFalse(settings.isCurrentlyDND(atHour: 2))
    }

    // MARK: - Simple range (start <= end, e.g. 9-17)

    func test_isCurrentlyDND_withinRange_returnsTrue() {
        var settings = UserSettings.default
        settings.dndEnabled = true
        settings.dndStartHour = 9
        settings.dndEndHour = 17
        XCTAssertTrue(settings.isCurrentlyDND(atHour: 9))
        XCTAssertTrue(settings.isCurrentlyDND(atHour: 12))
        XCTAssertTrue(settings.isCurrentlyDND(atHour: 16))
    }

    func test_isCurrentlyDND_outsideRange_returnsFalse() {
        var settings = UserSettings.default
        settings.dndEnabled = true
        settings.dndStartHour = 9
        settings.dndEndHour = 17
        XCTAssertFalse(settings.isCurrentlyDND(atHour: 8))
        XCTAssertFalse(settings.isCurrentlyDND(atHour: 17))
        XCTAssertFalse(settings.isCurrentlyDND(atHour: 23))
    }

    // MARK: - Overnight range (start > end, e.g. 22-8)

    func test_isCurrentlyDND_overnightRange_lateHour_returnsTrue() {
        var settings = UserSettings.default
        settings.dndEnabled = true
        settings.dndStartHour = 22
        settings.dndEndHour = 8
        XCTAssertTrue(settings.isCurrentlyDND(atHour: 22))
        XCTAssertTrue(settings.isCurrentlyDND(atHour: 23))
        XCTAssertTrue(settings.isCurrentlyDND(atHour: 0))
        XCTAssertTrue(settings.isCurrentlyDND(atHour: 7))
    }

    func test_isCurrentlyDND_overnightRange_middleOfDay_returnsFalse() {
        var settings = UserSettings.default
        settings.dndEnabled = true
        settings.dndStartHour = 22
        settings.dndEndHour = 8
        XCTAssertFalse(settings.isCurrentlyDND(atHour: 8))
        XCTAssertFalse(settings.isCurrentlyDND(atHour: 12))
        XCTAssertFalse(settings.isCurrentlyDND(atHour: 21))
    }

    // MARK: - Default settings

    func test_default_isPausedFalse() {
        XCTAssertFalse(UserSettings.default.isPaused)
    }

    func test_default_dndDisabled() {
        XCTAssertFalse(UserSettings.default.dndEnabled)
    }

    func test_default_hasShowAction() {
        XCTAssertEqual(UserSettings.default.customActions.count, 2)
        XCTAssertEqual(UserSettings.default.customActions.first?.kind, .showIDE)
        XCTAssertEqual(UserSettings.default.customActions.last?.kind, .copyCwd)
    }

    func test_default_enabledEventTypesNotEmpty() {
        XCTAssertFalse(UserSettings.default.enabledEventTypes.isEmpty)
    }

    // MARK: - Codable round-trip

    func test_codableRoundTrip_preservesAllFields() throws {
        let original = UserSettings.default
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserSettings.self, from: data)
        XCTAssertEqual(original, decoded)
    }
}
