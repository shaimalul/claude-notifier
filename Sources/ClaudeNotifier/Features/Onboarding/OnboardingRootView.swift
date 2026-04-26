import SwiftUI

struct OnboardingRootView: View {
    @State private var currentStep: Int = 0

    private let totalSteps: Int = 4

    var body: some View {
        VStack(spacing: 16) {
            Group {
                switch currentStep {
                case 0: WelcomeStepView()
                case 1: NotificationPermissionStepView()
                case 2: AccessibilityPermissionStepView()
                case 3: PluginInstallStepView()
                default: EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            stepIndicator

            HStack {
                Spacer()
                Button(currentStep == totalSteps - 1 ? "Get Started" : "Continue") {
                    handleAdvance()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(width: 520, height: 420)
    }

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index == currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private func handleAdvance() {
        if currentStep == totalSteps - 1 {
            OnboardingCoordinator.shared.complete()
        } else {
            currentStep += 1
        }
    }
}
