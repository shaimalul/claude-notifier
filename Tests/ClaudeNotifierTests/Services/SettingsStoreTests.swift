@testable import ClaudeNotifier
import XCTest

final class SettingsStoreTests: XCTestCase {
    private let store = SettingsStore.shared
    private var originalSettings: UserSettings!

    override func setUp() {
        super.setUp()
        originalSettings = store.settings
    }

    override func tearDown() {
        store.settings = originalSettings
        super.tearDown()
    }

    func test_reset_restoresDefaultSettings() {
        store.settings.isPaused = true
        store.settings.soundVolume = 0.1
        store.reset()
        XCTAssertEqual(store.settings, UserSettings.default)
    }

    func test_settingsMutation_persists() {
        store.settings.isPaused = true
        XCTAssertTrue(store.settings.isPaused)

        store.settings.isPaused = false
        XCTAssertFalse(store.settings.isPaused)
    }

    func test_soundVolume_canBeChanged() {
        store.settings.soundVolume = 0.75
        XCTAssertEqual(store.settings.soundVolume, 0.75, accuracy: 0.001)
    }

    func test_titleTemplate_canBeChanged() {
        store.settings.titleTemplate = "{project} - Claude"
        XCTAssertEqual(store.settings.titleTemplate, "{project} - Claude")
    }

    func test_customActions_canBeAppended() {
        let newAction = CustomAction(id: "test-id", title: "Test", kind: .copyCwd)
        store.settings.customActions.append(newAction)
        XCTAssertTrue(store.settings.customActions.contains(newAction))
    }

    func test_enabledEventTypes_canBeModified() {
        store.settings.enabledEventTypes = ["permission_prompt"]
        XCTAssertEqual(store.settings.enabledEventTypes, ["permission_prompt"])
    }

    func test_isPaused_defaultIsFalse() {
        store.reset()
        XCTAssertFalse(store.settings.isPaused)
    }
}
