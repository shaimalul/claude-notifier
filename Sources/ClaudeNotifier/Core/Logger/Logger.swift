import Foundation

final class Logger: LoggerProtocol {
    static let shared = Logger(fileLogger: FileLogger())

    private let fileLogger: FileLoggerProtocol

    // Cache date formatter for performance (avoid creating per log call)
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()

    init(fileLogger: FileLoggerProtocol) {
        self.fileLogger = fileLogger
    }

    func log(_ message: String, category: String = "App") {
        let timestamp = dateFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] [\(category)] \(message)"
        NSLog("%@", message)
        fileLogger.write(logMessage)
    }
}
