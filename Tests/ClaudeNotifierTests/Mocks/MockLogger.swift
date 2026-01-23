import Foundation
@testable import ClaudeNotifier

final class MockLogger: LoggerProtocol {
    var loggedMessages: [(message: String, category: String)] = []

    func log(_ message: String, category: String) {
        loggedMessages.append((message, category))
    }

    func hasLogged(containing text: String) -> Bool {
        loggedMessages.contains { $0.message.contains(text) }
    }

    func reset() {
        loggedMessages.removeAll()
    }
}
