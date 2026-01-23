@testable import ClaudeNotifier
import Foundation
import Network
import XCTest

final class RequestHandlerTests: XCTestCase {
    var mockResponseBuilder: MockResponseBuilder!
    var mockLogger: MockLogger!
    var receivedNotifications: [ClaudeNotification] = []

    override func setUp() {
        super.setUp()
        mockResponseBuilder = MockResponseBuilder()
        mockLogger = MockLogger()
        receivedNotifications = []
    }

    override func tearDown() {
        mockResponseBuilder.reset()
        mockLogger.reset()
        receivedNotifications = []
        super.tearDown()
    }

    private func createHandler() -> RequestHandler {
        RequestHandler(
            onNotification: { [weak self] in self?.receivedNotifications.append($0) },
            responseBuilder: mockResponseBuilder,
            logger: mockLogger
        )
    }

    private func makeConnection() -> NWConnection {
        NWConnection(host: "127.0.0.1", port: 1, using: .tcp)
    }

    // MARK: - HTTP Validation Tests

    func testRejectsEmptyRequest() {
        createHandler().handle(request: "", connection: makeConnection())
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 400)
    }

    func testRejectsInvalidRequestLine() {
        createHandler().handle(request: "INVALID", connection: makeConnection())
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 400)
    }

    func testRejectsInvalidHTTPVersion() {
        createHandler().handle(request: "POST /notify HTTP/2.0\r\n\r\n{}", connection: makeConnection())
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 400)
        XCTAssertTrue(mockResponseBuilder.buildCalls.first?.body.contains("Unsupported") ?? false)
    }

    func testRejectsUnsupportedMethod() {
        createHandler().handle(request: "DELETE /notify HTTP/1.1\r\n\r\n", connection: makeConnection())
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 405)
    }

    func testRejectsPathTraversal() {
        createHandler().handle(request: "GET /../etc/passwd HTTP/1.1\r\n\r\n", connection: makeConnection())
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 400)
        XCTAssertTrue(mockResponseBuilder.buildCalls.first?.body.contains("Invalid path") ?? false)
    }

    func testRejectsPathWithoutLeadingSlash() {
        createHandler().handle(request: "GET notify HTTP/1.1\r\n\r\n", connection: makeConnection())
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 400)
    }

    func testReturns404ForUnknownPath() {
        createHandler().handle(request: "GET /unknown HTTP/1.1\r\n\r\n", connection: makeConnection())
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 404)
    }

    // MARK: - Health Endpoint Tests

    func testHealthEndpointReturnsOK() {
        createHandler().handle(request: "GET /health HTTP/1.1\r\n\r\n", connection: makeConnection())
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 200)
        XCTAssertTrue(mockResponseBuilder.buildCalls.first?.body.contains("ok") ?? false)
    }

    // MARK: - Notify Endpoint Tests

    func testNotifyRejectsMissingBody() {
        createHandler().handle(request: "POST /notify HTTP/1.1\r\n", connection: makeConnection())
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 400)
        XCTAssertTrue(mockResponseBuilder.buildCalls.first?.body.contains("Missing body") ?? false)
    }

    func testNotifyRejectsOversizedPayload() {
        let largeBody = String(repeating: "x", count: 10000)
        let request = "POST /notify HTTP/1.1\r\nContent-Type: application/json\r\n\r\n\(largeBody)"
        createHandler().handle(request: request, connection: makeConnection())
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 413)
    }

    func testNotifyRejectsInvalidJSON() {
        let request = "POST /notify HTTP/1.1\r\nContent-Type: application/json\r\n\r\n{invalid}"
        createHandler().handle(request: request, connection: makeConnection())
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 400)
        XCTAssertTrue(mockResponseBuilder.buildCalls.first?.body.contains("Invalid JSON") ?? false)
    }

    func testNotifyAcceptsValidPayload() {
        let json = "{\"message\":\"test\",\"cwd\":\"/tmp\",\"sessionId\":\"1\",\"type\":\"t\",\"timestamp\":0}"
        let request = "POST /notify HTTP/1.1\r\nContent-Type: application/json\r\n\r\n\(json)"
        createHandler().handle(request: request, connection: makeConnection())
        XCTAssertEqual(mockResponseBuilder.buildCalls.first?.statusCode, 200)
    }
}
