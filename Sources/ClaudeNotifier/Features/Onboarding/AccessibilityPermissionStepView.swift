import AppKit
import SwiftUI

struct AccessibilityPermissionStepView: View {
    @State private var accessGranted: Bool = false

    var body: some View {
        VStack(spacing: 14) {
            Spacer()

            Image(systemName: "lock.rectangle.stack.fill")
                .font(.system(size: 60))
                .foregroundColor(.purple)

            Text("Allow Accessibility Access")
                .font(.title)
                .fontWeight(.semibold)

            Text("Accessibility access lets Claude Notifier focus the right IDE window when you click a notification.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            HStack(spacing: 8) {
                Image(systemName: accessGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(accessGranted ? .green : .red)
                Text(accessGranted ? "Access granted" : "Not granted")
                    .foregroundColor(accessGranted ? .green : .red)
                    .fontWeight(.medium)
            }
            .padding(.top, 4)

            if !accessGranted {
                Button("Open System Settings") {
                    handleOpenSettings()
                }
                .padding(.top, 4)
            }

            Text("If you skip this, notifications will still appear - you just won't auto-jump to the IDE window.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 4)

            Spacer()
        }
        .padding()
        .onAppear(perform: handleCheckAccess)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            handleCheckAccess()
        }
    }

    private func handleCheckAccess() {
        accessGranted = AXIsProcessTrusted()
    }

    private func handleOpenSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
