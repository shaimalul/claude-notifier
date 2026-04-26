import SwiftUI

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "bell.badge")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("Welcome to Claude Notifier")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text(
                "Get notified when Claude Code needs your attention - and jump straight to the right IDE window with one click."
            )
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)

            Text("Let's get you set up in 3 quick steps.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }
}
