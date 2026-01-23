import Foundation

protocol LoggerProtocol {
    func log(_ message: String, category: String)
}

extension LoggerProtocol {
    func log(_ message: String) {
        log(message, category: "App")
    }
}
