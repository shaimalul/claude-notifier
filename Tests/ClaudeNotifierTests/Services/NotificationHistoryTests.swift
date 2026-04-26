@testable import ClaudeNotifier
import XCTest

final class NotificationHistoryTests: XCTestCase {
    private let history = NotificationHistory.shared

    override func setUp() {
        super.setUp()
        history.clear()
    }

    override func tearDown() {
        history.clear()
        super.tearDown()
    }

    private func makeNotification(message: String = "test") -> ClaudeNotification {
        ClaudeNotification(
            message: message,
            cwd: "/tmp/project",
            sessionId: "session-1",
            type: "unknown",
            timestamp: Date().timeIntervalSince1970
        )
    }

    func test_add_insertsAtFront() {
        history.add(makeNotification(message: "first"))
        history.add(makeNotification(message: "second"))
        XCTAssertEqual(history.recent.first?.message, "second")
        XCTAssertEqual(history.recent.last?.message, "first")
    }

    func test_add_withSingleItem_hasCountOfOne() {
        history.add(makeNotification())
        XCTAssertEqual(history.recent.count, 1)
    }

    func test_add_beyondFiveItems_capsAtFive() {
        for i in 0 ..< 8 {
            history.add(makeNotification(message: "msg-\(i)"))
        }
        XCTAssertEqual(history.recent.count, 5)
    }

    func test_add_beyondFiveItems_keepsNewest() {
        for i in 0 ..< 7 {
            history.add(makeNotification(message: "msg-\(i)"))
        }
        XCTAssertEqual(history.recent.first?.message, "msg-6")
    }

    func test_initialState_isEmpty() {
        XCTAssertTrue(history.recent.isEmpty)
    }

    func test_add_exactlyFive_keepsAll() {
        for i in 0 ..< 5 {
            history.add(makeNotification(message: "msg-\(i)"))
        }
        XCTAssertEqual(history.recent.count, 5)
    }
}
