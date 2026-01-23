import Foundation

final class Logger: LoggerProtocol {
    static let shared = Logger(fileLogger: FileLogger())

    private let fileLogger: FileLoggerProtocol

    init(fileLogger: FileLoggerProtocol) {
        self.fileLogger = fileLogger
    }

    func log(_ message: String, category: String = "App") {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logMessage = "[\(timestamp)] [\(category)] \(message)"
        NSLog("%@", message)
        fileLogger.write(logMessage)
    }
}
