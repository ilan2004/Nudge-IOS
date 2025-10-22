import SwiftUI

struct MBTIResultView: View {
    let type: PersonalityType
    let onContinue: () -> Void

    @State private var animate = false

    private var titleText: String { type.displayName }

    var body: some View {
        ZStack {
            // Background using themed color
            Color(red: 130/255, green: 237/255, blue: 166/255)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Your Type Is")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))

                Text(type.rawValue)
                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .scaleEffect(animate ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: animate)

                Text(titleText)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeInOut.delay(0.2), value: animate)

                Spacer().frame(height: 20)

                Button(action: onContinue) {
                    HStack { Spacer(); Text("Continue").font(.headline); Spacer() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(Color(red: 0.055, green: 0.259, blue: 0.184))
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .padding()
        }
        .onAppear { animate = true }
    }
}

#Preview {
    MBTIResultView(type: .enfj) {}
}

