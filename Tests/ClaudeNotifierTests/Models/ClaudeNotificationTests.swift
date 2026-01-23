import XCTest
@testable import ClaudeNotifier

final class ClaudeNotificationTests: XCTestCase {
    func test_init_setsAllProperties() {
        let notification = ClaudeNotification(
            message: "Test message",
            cwd: "/Users/test/project",
            sessionId: "abc123",
            type: "permission_prompt",
            timestamp: 1234567890
        )

        XCTAssertEqual(notification.message, "Test message")
        XCTAssertEqual(notification.cwd, "/Users/test/project")
        XCTAssertEqual(notification.sessionId, "abc123")
        XCTAssertEqual(notification.type, .permissionPrompt)
        XCTAssertFalse(notification.isRead)
    }

    func test_projectName_extractsLastPathComponent() {
        let notification = ClaudeNotification(
            message: "Test",
            cwd: "/Users/test/my-project",
            sessionId: "123",
            type: "unknown",
            timestamp: 0
        )

        XCTAssertEqual(notification.projectName, "my-project")
    }

    func test_notificationType_permissionPrompt() {
        let notification = ClaudeNotification(
            message: "Test",
            cwd: "/test",
            sessionId: "123",
            type: "permission_prompt",
            timestamp: 0
        )

        XCTAssertEqual(notification.type, .permissionPrompt)
        XCTAssertEqual(notification.typeDisplayName, "Permission Request")
        XCTAssertEqual(notification.typeIcon, "lock.shield")
    }

    func test_notificationType_idlePrompt() {
        let notification = ClaudeNotification(
            message: "Test",
            cwd: "/test",
            sessionId: "123",
            type: "idle_prompt",
            timestamp: 0
        )

        XCTAssertEqual(notification.type, .idlePrompt)
        XCTAssertEqual(notification.typeDisplayName, "Waiting for Input")
        XCTAssertEqual(notification.typeIcon, "clock")
    }

    func test_notificationType_elicitationDialog() {
        let notification = ClaudeNotification(
            message: "Test",
            cwd: "/test",
            sessionId: "123",
            type: "elicitation_dialog",
            timestamp: 0
        )

        XCTAssertEqual(notification.type, .elicitationDialog)
        XCTAssertEqual(notification.typeDisplayName, "Input Required")
        XCTAssertEqual(notification.typeIcon, "text.bubble")
    }

    func test_notificationType_unknown_forInvalidType() {
        let notification = ClaudeNotification(
            message: "Test",
            cwd: "/test",
            sessionId: "123",
            type: "invalid_type",
            timestamp: 0
        )

        XCTAssertEqual(notification.type, .unknown)
        XCTAssertEqual(notification.typeDisplayName, "Notification")
        XCTAssertEqual(notification.typeIcon, "bell")
    }

    func test_timestamp_convertsFromTimeInterval() {
        let timestamp: TimeInterval = 1700000000
        let notification = ClaudeNotification(
            message: "Test",
            cwd: "/test",
            sessionId: "123",
            type: "unknown",
            timestamp: timestamp
        )

        XCTAssertEqual(notification.timestamp, Date(timeIntervalSince1970: timestamp))
    }

    func test_id_isUniqueForEachInstance() {
        let notification1 = ClaudeNotification(
            message: "Test",
            cwd: "/test",
            sessionId: "123",
            type: "unknown",
            timestamp: 0
        )
        let notification2 = ClaudeNotification(
            message: "Test",
            cwd: "/test",
            sessionId: "123",
            type: "unknown",
            timestamp: 0
        )

        XCTAssertNotEqual(notification1.id, notification2.id)
    }
}
