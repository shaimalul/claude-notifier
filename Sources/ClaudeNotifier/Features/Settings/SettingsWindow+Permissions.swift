import AppKit
import SwiftUI
import UserNotifications

extension SettingsWindow {
    var permissionsSection: some View {
        Section {
            permissionRow(
                icon: "bell.badge.fill",
                title: "Notifications",
                description: "Required to deliver Claude alerts",
                isGranted: notificationPermission == .authorized || notificationPermission == .provisional,
                onFix: { requestNotificationPermission() }
            )
            permissionRow(
                icon: "accessibility",
                title: "Accessibility",
                description: "Optional — used to focus IDE windows on tap",
                isGranted: accessibilityGranted,
                onFix: { openAccessibilitySettings() }
            )
        } header: {
            sectionHeader("Permissions", icon: "checkmark.shield")
        }
    }

    func permissionRow(
        icon: String,
        title: String,
        description: String,
        isGranted: Bool,
        onFix: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            permissionIcon(icon)
            permissionLabels(title: title, description: description)
            Spacer()
            permissionStatus(isGranted: isGranted, onFix: onFix)
        }
        .padding(.vertical, 3)
    }

    private func permissionIcon(_ icon: String) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.iconBackground)
            .frame(width: 32, height: 32)
            .overlay { depthGlow(size: 32) }
            .overlay {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.iconForeground)
            }
    }

    private func permissionLabels(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(size: 13, weight: .medium))
            Text(description).font(.system(size: 11)).foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func permissionStatus(isGranted: Bool, onFix: @escaping () -> Void) -> some View {
        if isGranted {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                Text("Granted").foregroundColor(.green)
            }
            .font(.system(size: 12, weight: .medium))
        } else {
            Button("Enable") { onFix() }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.brandPrimary)
        }
    }

    func depthGlow(size: CGFloat) -> some View {
        RadialGradient(
            colors: [
                Color(red: 0.20, green: 0.20, blue: 0.30).opacity(0.5),
                Color(red: 0.07, green: 0.07, blue: 0.10).opacity(0)
            ],
            center: .center,
            startRadius: 0,
            endRadius: size * 0.70
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    func refreshPermissions() {
        accessibilityGranted = AXIsProcessTrusted()
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { notificationPermission = settings.authorizationStatus }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async { notificationPermission = granted ? .authorized : .denied }
        }
    }

    private func openAccessibilitySettings() {
        _ = AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        )
    }
}
