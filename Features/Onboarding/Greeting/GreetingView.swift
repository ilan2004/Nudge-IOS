import SwiftUI

struct GreetingView: View {
    let name: String
    var onNext: () -> Void

    @State private var showNext = false

    var body: some View {
        VStack(spacing: 24) {
            ProgressBar(progress: 1.0)
                .frame(height: 8)
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 16) {
                TypewriterText(
                    text: "\(name), we’re so glad you’re here.",
                    charInterval: 0.1,
                    color: .nudgeGreen900,
                    hapticStyle: .medium
                ) {
                    withAnimation(.easeIn(duration: 0.3)) { showNext = true }
                }

                if showNext {
                    Button("Next") { onNext() }
                        .buttonStyle(NavPillStyle(variant: .primary))
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
    }
}

