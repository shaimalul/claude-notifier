@testable import ClaudeNotifier
import XCTest

// Tests the template rendering logic used by NotificationService
// by validating the token substitution contract
final class NotificationTemplateTests: XCTestCase {
    private func applyTemplate(_ template: String, to notification: ClaudeNotification) -> String {
        template
            .replacingOccurrences(of: "{project}", with: notification.projectName)
            .replacingOccurrences(of: "{message}", with: notification.message)
            .replacingOccurrences(of: "{sessionId}", with: notification.sessionId)
    }

    private func makeNotification(
        message: String = "Permission requested",
        cwd: String = "/Users/dev/my-app",
        sessionId: String = "sess-42"
    ) -> ClaudeNotification {
        ClaudeNotification(message: message, cwd: cwd, sessionId: sessionId, type: "unknown", timestamp: 0)
    }

    func test_projectToken_substitutedWithLastPathComponent() {
        let n = makeNotification(cwd: "/Users/dev/my-app")
        XCTAssertEqual(applyTemplate("{project}", to: n), "my-app")
    }

    func test_messageToken_substituted() {
        let n = makeNotification(message: "Hello Claude")
        XCTAssertEqual(applyTemplate("{message}", to: n), "Hello Claude")
    }

    func test_sessionIdToken_substituted() {
        let n = makeNotification(sessionId: "abc-123")
        XCTAssertEqual(applyTemplate("{sessionId}", to: n), "abc-123")
    }

    func test_compositeTemplate_allTokensSubstituted() {
        let n = makeNotification(message: "Waiting", cwd: "/home/user/cool-project", sessionId: "s1")
        let result = applyTemplate("[{project}] {message} ({sessionId})", to: n)
        XCTAssertEqual(result, "[cool-project] Waiting (s1)")
    }

    func test_templateWithNoTokens_returnedAsIs() {
        let n = makeNotification()
        XCTAssertEqual(applyTemplate("Claude needs you", to: n), "Claude needs you")
    }

    func test_defaultTitleTemplate_producesProjectName() {
        let n = makeNotification(cwd: "/repos/my-project")
        XCTAssertEqual(applyTemplate(UserSettings.default.titleTemplate, to: n), "my-project")
    }

    func test_defaultBodyTemplate_producesMessage() {
        let n = makeNotification(message: "Bash tool requested")
        XCTAssertEqual(applyTemplate(UserSettings.default.bodyTemplate, to: n), "Bash tool requested")
    }
}
