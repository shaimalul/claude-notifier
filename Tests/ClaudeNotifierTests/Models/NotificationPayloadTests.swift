@testable import ClaudeNotifier
import XCTest

final class NotificationPayloadTests: XCTestCase {
    func test_decodingFromJSON_succeeds() throws {
        let json = """
        {
            "message": "Claude is asking a question",
            "cwd": "/Users/test/project",
            "sessionId": "session-123",
            "type": "permission_prompt",
            "timestamp": 1700000000
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        let payload = try JSONDecoder().decode(NotificationPayload.self, from: data)

        XCTAssertEqual(payload.message, "Claude is asking a question")
        XCTAssertEqual(payload.cwd, "/Users/test/project")
        XCTAssertEqual(payload.sessionId, "session-123")
        XCTAssertEqual(payload.type, "permission_prompt")
        XCTAssertEqual(payload.timestamp, 1_700_000_000)
    }

    func test_toClaudeNotification_createsCorrectNotification() {
        let payload = NotificationPayload(
            message: "Test message",
            cwd: "/Users/test/my-app",
            sessionId: "abc-123",
            type: "idle_prompt",
            timestamp: 1_700_000_000,
            ideBundleId: nil,
            responsePipe: nil
        )

        let notification = payload.toClaudeNotification()

        XCTAssertEqual(notification.message, "Test message")
        XCTAssertEqual(notification.cwd, "/Users/test/my-app")
        XCTAssertEqual(notification.sessionId, "abc-123")
        XCTAssertEqual(notification.type, ClaudeNotification.NotificationType.idlePrompt)
        XCTAssertEqual(notification.projectName, "my-app")
    }

    func test_decodingWithMissingField_fails() throws {
        let json = """
        {
            "message": "Test",
            "cwd": "/test"
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        XCTAssertThrowsError(try JSONDecoder().decode(NotificationPayload.self, from: data))
    }

    func test_encodingToJSON_succeeds() throws {
        let payload = NotificationPayload(
            message: "Test",
            cwd: "/test",
            sessionId: "123",
            type: "unknown",
            timestamp: 0,
            ideBundleId: nil,
            responsePipe: nil
        )

        let data = try JSONEncoder().encode(payload)
        let decoded = try JSONDecoder().decode(NotificationPayload.self, from: data)

        XCTAssertEqual(decoded.message, payload.message)
        XCTAssertEqual(decoded.cwd, payload.cwd)
        XCTAssertEqual(decoded.sessionId, payload.sessionId)
    }
}
