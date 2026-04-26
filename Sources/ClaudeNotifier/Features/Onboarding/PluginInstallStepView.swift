import SwiftUI

struct PluginInstallStepView: View {
    enum InstallState {
        case idle
        case installing
        case success(String)
        case failed(String)
    }

    @State private var installState: InstallState = .idle

    var body: some View {
        VStack(spacing: 14) {
            Spacer()

            Image(systemName: "puzzlepiece.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Install Claude Code Plugin")
                .font(.title)
                .fontWeight(.semibold)

            Text("The Claude Notifier plugin hooks into Claude Code to send you notifications.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            stateView

            Spacer()
        }
        .padding()
        .onAppear {
            if case .idle = installState, PluginInstaller.shared.verifyInstalled() {
                installState = .success("Plugin already installed")
            }
        }
    }

    @ViewBuilder
    private var stateView: some View {
        switch installState {
        case .idle:
            Button("Install Plugin") {
                Task { await handleInstallPlugin() }
            }
            .padding(.top, 8)
        case .installing:
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("Installing...")
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        case let .success(message):
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(message)
                    .foregroundColor(.green)
            }
            .padding(.top, 8)
        case let .failed(message):
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text(message)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                Button("Retry") {
                    Task { await handleInstallPlugin() }
                }
            }
            .padding(.top, 8)
        }
    }

    private func handleInstallPlugin() async {
        await MainActor.run { installState = .installing }

        let result: Result<PluginInstaller.InstallResult, Error> = await Task.detached {
            do {
                let installResult = try PluginInstaller.shared.install()
                return .success(installResult)
            } catch {
                return .failure(error)
            }
        }.value

        await MainActor.run {
            switch result {
            case let .success(installResult):
                installState = .success(messageFor(installResult))
            case let .failure(error):
                installState = .failed("Installation failed: \(error.localizedDescription)")
            }
        }
    }

    private func messageFor(_ result: PluginInstaller.InstallResult) -> String {
        switch result {
        case .installed: "Plugin installed successfully"
        case .alreadyInstalled: "Plugin already installed"
        case .replacedDevInstall: "Replaced dev install with release plugin"
        }
    }
}
