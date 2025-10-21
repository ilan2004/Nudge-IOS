import SwiftUI

struct OnboardingChoiceView: View {
    var onTakeTest: () -> Void
    var onStartBlocking: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("How would you like to continue?")
                    .font(.title2).fontWeight(.semibold)
                    .foregroundStyle(Color.nudgeGreen900)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 16) {
                Button("Take MBTI Test") { onTakeTest() }
                    .buttonStyle(NavPillStyle(variant: .primary))
                Button("Start Blocking Now") { onStartBlocking() }
                    .buttonStyle(NavPillStyle(variant: .primary))
            }
            .padding(.horizontal, 20)

            Spacer()
        }
    }
}

