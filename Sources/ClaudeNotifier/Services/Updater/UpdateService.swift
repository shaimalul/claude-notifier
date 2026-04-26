import AppKit
import Foundation

final class UpdateService {
    static let shared = UpdateService()

    private static let releasesURL = "https://github.com/shaimalul/claude-notifier/releases/latest"

    private init() {}

    var canCheckForUpdates: Bool { true }

    func checkForUpdates() {
        guard let url = URL(string: Self.releasesURL) else { return }
        NSWorkspace.shared.open(url)
    }
}
