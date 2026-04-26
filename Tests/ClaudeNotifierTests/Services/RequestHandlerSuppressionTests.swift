@testable import ClaudeNotifier
import Foundation
import Network
import XCTest

final class RequestHandlerSuppressionTests: XCTestCase {
    private var mockResponseBuilder: MockResponseBuilder!
    private var mockLogger: MockLogger!
    private var receivedNotifications: [ClaudeNotification] = []
    private var originalSettings: UserSettings!

    override func setUp() {
        super.setUp()
        mockResponseBuilder = MockResponseBuilder()
        mockLogger = MockLogger()
        receivedNotifications = []
        originalSettings = SettingsStore.shared.settings
    }

    override func tearDown() {
        SettingsStore.shared.settings = originalSettings
        ActionDispatcher.shared.clearSnooze()
        mockResponseBuilder.reset()
        mockLogger.reset()
        super.tearDown()
    }

    private func makeHandler() -> RequestHandler {
        RequestHandler(
            onNotification: { [weak self] in self?.receivedNotifications.append($0) },
            responseBuilder: mockResponseBuilder,
            logger: mockLogger
        )
    }

    private func validNotifyRequest() -> String {
        let json = "{\"message\":\"test\",\"cwd\":\"/tmp\",\"sessionId\":\"1\",\"type\":\"unknown\",\"timestamp\":0}"
        return "POST /notify HTTP/1.1\r\nContent-Type: application/json\r\n\r\n\(json)"
    }

    func test_notify_suppressed_whenPaused() {
        SettingsStore.shared.settings.isPaused = true
        makeHandler().handle(
            request: validNotifyRequest(),
            connection: NWConnection(host: "127.0.0.1", port: 1, using: .tcp)
        )
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 200)
        XCTAssertTrue(mockResponseBuilder.buildCalls.first?.body.contains("suppressed") ?? false)
        XCTAssertTrue(receivedNotifications.isEmpty)
    }

    func test_notify_suppressed_whenSnoozed() {
        ActionDispatcher.shared.activateSnooze(minutes: 5)
        makeHandler().handle(
            request: validNotifyRequest(),
            connection: NWConnection(host: "127.0.0.1", port: 1, using: .tcp)
        )
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 200)
        XCTAssertTrue(mockResponseBuilder.buildCalls.first?.body.contains("suppressed") ?? false)
        XCTAssertTrue(receivedNotifications.isEmpty)
    }

    func test_notify_suppressed_whenDNDActive() {
        SettingsStore.shared.settings.dndEnabled = true
        SettingsStore.shared.settings.dndStartHour = 0
        SettingsStore.shared.settings.dndEndHour = 23
        makeHandler().handle(
            request: validNotifyRequest(),
            connection: NWConnection(host: "127.0.0.1", port: 1, using: .tcp)
        )
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 200)
        XCTAssertTrue(mockResponseBuilder.buildCalls.first?.body.contains("suppressed") ?? false)
        XCTAssertTrue(receivedNotifications.isEmpty)
    }

    func test_notify_notSuppressed_withDefaultSettings() {
        makeHandler().handle(
            request: validNotifyRequest(),
            connection: NWConnection(host: "127.0.0.1", port: 1, using: .tcp)
        )
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 200)
        XCTAssertFalse(mockResponseBuilder.buildCalls.first?.body.contains("suppressed") ?? true)
    }
}
