@testable import ClaudeNotifier
import Foundation

final class MockResponseBuilder: ResponseBuilderProtocol {
    var buildCalls: [(statusCode: Int, body: String)] = []
    var mockResponse: Data?

    func build(statusCode: Int, body: String) -> Data? {
        buildCalls.append((statusCode, body))
        return mockResponse ?? body.data(using: .utf8)
    }

    func reset() {
        buildCalls.removeAll()
        mockResponse = nil
    }
}
