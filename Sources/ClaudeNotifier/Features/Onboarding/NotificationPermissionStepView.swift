import SwiftUI
import UserNotifications

struct NotificationPermissionStepView: View {
    @State private var permissionGranted: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Allow Notifications")
                .font(.title)
                .fontWeight(.semibold)

            Text("Claude Notifier needs permission to show you alerts when Claude Code is waiting.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if permissionGranted {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Notifications enabled")
                        .foregroundColor(.green)
                }
                .padding(.top, 8)
            } else {
                Button("Allow Notifications") {
                    handleRequestPermission()
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: handleCheckPermission)
    }

    private func handleCheckPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                permissionGranted = settings.authorizationStatus == .authorized
                    || settings.authorizationStatus == .provisional
            }
        }
    }

    private func handleRequestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                permissionGranted = granted
            }
        }
    }
}
