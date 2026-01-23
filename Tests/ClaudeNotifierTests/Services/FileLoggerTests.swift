@testable import ClaudeNotifier
import XCTest

final class FileLoggerTests: XCTestCase {
    var testFilePath: String!
    var sut: FileLogger!

    override func setUp() {
        super.setUp()
        testFilePath = NSTemporaryDirectory() + "test_log_\(UUID().uuidString).log"
        sut = FileLogger(filePath: testFilePath)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(atPath: testFilePath)
        sut = nil
        testFilePath = nil
        super.tearDown()
    }

    func test_write_createsFileIfNotExists() {
        XCTAssertFalse(FileManager.default.fileExists(atPath: testFilePath))

        sut.write("Test message")

        XCTAssertTrue(FileManager.default.fileExists(atPath: testFilePath))
    }

    func test_write_appendsToExistingFile() throws {
        sut.write("First message")
        sut.write("Second message")

        let content = try String(contentsOfFile: testFilePath, encoding: .utf8)
        XCTAssertTrue(content.contains("First message"))
        XCTAssertTrue(content.contains("Second message"))
    }

    func test_write_addsNewlineAfterMessage() throws {
        sut.write("Test")

        let content = try String(contentsOfFile: testFilePath, encoding: .utf8)
        XCTAssertTrue(content.hasSuffix("\n"))
    }
}
