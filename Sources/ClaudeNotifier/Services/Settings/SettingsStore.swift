import Combine
import Foundation

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    private static let defaultsKey = "com.claude.notifier.settings"

    @Published var settings: UserSettings {
        didSet { persist() }
    }

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.defaultsKey),
           let decoded = try? JSONDecoder().decode(UserSettings.self, from: data)
        {
            settings = decoded
        } else {
            settings = .default
        }
    }

    func reset() {
        settings = .default
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: Self.defaultsKey)
    }
}

extension Notification.Name {
    static let settingsActionsDidChange = Notification.Name("settingsActionsDidChange")
}
