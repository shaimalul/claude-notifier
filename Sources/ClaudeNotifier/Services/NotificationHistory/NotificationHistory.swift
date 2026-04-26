import Foundation

final class NotificationHistory: ObservableObject {
    static let shared = NotificationHistory()

    private static let maxCount = 5

    @Published private(set) var recent: [ClaudeNotification] = []

    private init() {}

    func clear() {
        recent = []
    }

    func add(_ notification: ClaudeNotification) {
        recent.insert(notification, at: 0)
        if recent.count > Self.maxCount {
            recent = Array(recent.prefix(Self.maxCount))
        }
    }
}
