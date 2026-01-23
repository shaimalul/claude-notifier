@testable import ClaudeNotifier
import XCTest

final class LoggerTests: XCTestCase {
    var mockFileLogger: MockFileLogger!
    var sut: Logger!

    override func setUp() {
        super.setUp()
        mockFileLogger = MockFileLogger()
        sut = Logger(fileLogger: mockFileLogger)
    }

    override func tearDown() {
        sut = nil
        mockFileLogger = nil
        super.tearDown()
    }

    func test_log_writesToFileLogger() {
        sut.log("Test message", category: "Test")

        XCTAssertEqual(mockFileLogger.writtenMessages.count, 1)
    }

    func test_log_includesCategory() {
        sut.log("Test message", category: "MyCategory")

        XCTAssertTrue(mockFileLogger.hasWritten(containing: "[MyCategory]"))
    }

    func test_log_includesMessage() {
        sut.log("Hello world", category: "Test")

        XCTAssertTrue(mockFileLogger.hasWritten(containing: "Hello world"))
    }

    func test_log_includesTimestamp() {
        sut.log("Test", category: "Test")

        let message = mockFileLogger.writtenMessages.first!
        // ISO8601 timestamps start with year, e.g., "2024-"
        XCTAssertTrue(message.contains("[20"))
    }

    func test_log_withDefaultCategory_usesApp() {
        sut.log("Test message")

        XCTAssertTrue(mockFileLogger.hasWritten(containing: "[App]"))
    }

    func test_multipleLogs_areAllRecorded() {
        sut.log("First", category: "A")
        sut.log("Second", category: "B")
        sut.log("Third", category: "C")

        XCTAssertEqual(mockFileLogger.writtenMessages.count, 3)
    }
}
