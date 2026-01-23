@testable import ClaudeNotifier
import Foundation

final class MockFileLogger: FileLoggerProtocol {
    var writtenMessages: [String] = []

    func write(_ message: String) {
        writtenMessages.append(message)
    }

    func hasWritten(containing text: String) -> Bool {
        writtenMessages.contains { $0.contains(text) }
    }

    func reset() {
        writtenMessages.removeAll()
    }
}
