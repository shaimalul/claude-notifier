@testable import ClaudeNotifier
import XCTest

final class ActionDispatcherTests: XCTestCase {
    private var dispatcher: ActionDispatcher!

    override func setUp() {
        super.setUp()
        dispatcher = ActionDispatcher()
    }

    func test_isSnoozed_initiallyFalse() {
        XCTAssertFalse(dispatcher.isSnoozed)
    }

    func test_isSnoozed_afterSnooze5m_returnsTrue() {
        dispatcher.activateSnooze(minutes: 5)
        XCTAssertTrue(dispatcher.isSnoozed)
    }

    func test_isSnoozed_afterSnooze15m_returnsTrue() {
        dispatcher.activateSnooze(minutes: 15)
        XCTAssertTrue(dispatcher.isSnoozed)
    }

    func test_isSnoozed_afterSnooze60m_returnsTrue() {
        dispatcher.activateSnooze(minutes: 60)
        XCTAssertTrue(dispatcher.isSnoozed)
    }

    func test_isSnoozed_afterClearSnooze_returnsFalse() {
        dispatcher.activateSnooze(minutes: 5)
        dispatcher.clearSnooze()
        XCTAssertFalse(dispatcher.isSnoozed)
    }
}
