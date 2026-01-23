import Foundation

protocol FileLoggerProtocol {
    func write(_ message: String)
}

final class FileLogger: FileLoggerProtocol {
    private let filePath: String

    init(filePath: String = AppConfig.logFilePath) {
        self.filePath = filePath
    }

    func write(_ message: String) {
        let logMessage = message + "\n"
        guard let data = logMessage.data(using: .utf8) else { return }

        if FileManager.default.fileExists(atPath: filePath) {
            if let handle = FileHandle(forWritingAtPath: filePath) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            }
        } else {
            FileManager.default.createFile(atPath: filePath, contents: data)
        }
    }
}
