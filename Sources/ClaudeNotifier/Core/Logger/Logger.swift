import Foundation

final class Logger: LoggerProtocol {
    static let shared = Logger(fileLogger: FileLogger())

    private let fileLogger: FileLoggerProtocol

    private let dateFormatter = ISO8601DateFormatter()

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
