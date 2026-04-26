import Foundation

final class PluginInstaller {
    static let shared = PluginInstaller()

    enum InstallResult {
        case alreadyInstalled
        case installed
        case replacedDevInstall
    }

    private init() {}

    private var pluginSourceURL: URL? {
        Bundle.main.resourceURL?.appendingPathComponent("plugin")
    }

    private var pluginDestURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/plugins/claude-notifier")
    }

    func install() throws -> InstallResult {
        guard let source = pluginSourceURL else {
            throw PluginInstallerError.sourceNotFound
        }

        let dest = pluginDestURL
        let fm = FileManager.default

        try fm.createDirectory(
            at: dest.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let destPath = dest.path
        let isSymlink = (try? fm.attributesOfItem(atPath: destPath))?[.type] as? FileAttributeType == .typeSymbolicLink

        if isSymlink {
            try fm.removeItem(at: dest)
            try fm.copyItem(at: source, to: dest)
            return .replacedDevInstall
        }

        if fm.fileExists(atPath: destPath) {
            return .alreadyInstalled
        }

        try fm.copyItem(at: source, to: dest)
        return .installed
    }

    func verifyInstalled() -> Bool {
        let path = pluginDestURL.path
        let fm = FileManager.default
        let isSymlink = (try? fm.attributesOfItem(atPath: path))?[.type] as? FileAttributeType == .typeSymbolicLink

        if isSymlink {
            return (try? fm.destinationOfSymbolicLink(atPath: path)) != nil
        }

        return fm.fileExists(atPath: path)
    }
}

enum PluginInstallerError: Error {
    case sourceNotFound
}
