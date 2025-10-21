import SwiftUI

enum OnboardingStep {
    case name
    case greeting
    case choice
}

struct OnboardingFlowView: View {
    @State private var step: OnboardingStep = .name
    @State private var userName: String = ""

    var onSkipToHome: () -> Void
    var onTakeTest: () -> Void

    var body: some View {
        Group {
            switch step {
            case .name:
                NameEntryView { name in
                    self.userName = name
                    withAnimation(.easeInOut) { step = .greeting }
                }
            case .greeting:
                GreetingView(name: userName) {
                    withAnimation(.easeInOut) { step = .choice }
                }
            case .choice:
                OnboardingChoiceView(
                    onTakeTest: onTakeTest,
                    onStartBlocking: onSkipToHome
                )
            }
        }
    }
}

