import XCTest
@testable import ClaudeNotifier

final class ResponseBuilderTests: XCTestCase {
    var sut: ResponseBuilder!

    override func setUp() {
        super.setUp()
        sut = ResponseBuilder()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_build_with200_returnsOKStatus() {
        let result = sut.build(statusCode: 200, body: "{\"status\":\"ok\"}")

        XCTAssertNotNil(result)
        let responseString = String(data: result!, encoding: .utf8)!
        XCTAssertTrue(responseString.contains("HTTP/1.1 200 OK"))
    }

    func test_build_with400_returnsBadRequestStatus() {
        let result = sut.build(statusCode: 400, body: "{\"error\":\"bad\"}")

        XCTAssertNotNil(result)
        let responseString = String(data: result!, encoding: .utf8)!
        XCTAssertTrue(responseString.contains("HTTP/1.1 400 Bad Request"))
    }

    func test_build_with404_returnsNotFoundStatus() {
        let result = sut.build(statusCode: 404, body: "{\"error\":\"not found\"}")

        XCTAssertNotNil(result)
        let responseString = String(data: result!, encoding: .utf8)!
        XCTAssertTrue(responseString.contains("HTTP/1.1 404 Not Found"))
    }

    func test_build_includesContentTypeHeader() {
        let result = sut.build(statusCode: 200, body: "{}")

        let responseString = String(data: result!, encoding: .utf8)!
        XCTAssertTrue(responseString.contains("Content-Type: application/json"))
    }

    func test_build_includesCorrectContentLength() {
        let body = "{\"test\":\"value\"}"
        let result = sut.build(statusCode: 200, body: body)

        let responseString = String(data: result!, encoding: .utf8)!
        XCTAssertTrue(responseString.contains("Content-Length: \(body.utf8.count)"))
    }

    func test_build_includesConnectionCloseHeader() {
        let result = sut.build(statusCode: 200, body: "{}")

        let responseString = String(data: result!, encoding: .utf8)!
        XCTAssertTrue(responseString.contains("Connection: close"))
    }

    func test_build_includesBodyContent() {
        let body = "{\"message\":\"hello world\"}"
        let result = sut.build(statusCode: 200, body: body)

        let responseString = String(data: result!, encoding: .utf8)!
        XCTAssertTrue(responseString.contains(body))
    }

    func test_build_withUnknownStatusCode_returnsUnknownText() {
        let result = sut.build(statusCode: 999, body: "{}")

        let responseString = String(data: result!, encoding: .utf8)!
        XCTAssertTrue(responseString.contains("HTTP/1.1 999 Unknown"))
    }
}
