import Foundation

protocol FileLoggerProtocol {
    func write(_ message: String)
}

final class FileLogger: FileLoggerProtocol {
    private let filePath: String

    init(filePath: String = AppConfig.logFilePath) {
        self.filePath = filePath
    }

    private let maxLogSizeBytes = 1_048_576 // 1MB
    private let maxLogFiles = 3

    func write(_ message: String) {
        let logMessage = message + "\n"
        guard let data = logMessage.data(using: .utf8) else { return }

        // Check if rotation needed
        if let attrs = try? FileManager.default.attributesOfItem(atPath: filePath),
           let size = attrs[.size] as? Int,
           size > maxLogSizeBytes
        {
            rotateLog()
        }

        // Create file if needed
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: data)
            return
        }

        // Write with proper resource management (fixed resource leak)
        if let handle = try? FileHandle(forWritingTo: URL(fileURLWithPath: filePath)) {
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        }
    }

    private func rotateLog() {
        for i in stride(from: maxLogFiles - 1, through: 1, by: -1) {
            let oldPath = "\(filePath).\(i)"
            let newPath = "\(filePath).\(i + 1)"
            try? FileManager.default.removeItem(atPath: newPath)
            try? FileManager.default.moveItem(atPath: oldPath, toPath: newPath)
        }
        try? FileManager.default.moveItem(atPath: filePath, toPath: "\(filePath).1")
    }
}
