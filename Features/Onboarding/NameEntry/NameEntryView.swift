import SwiftUI

struct NameEntryView: View {
    @State private var showControls = false
    @State private var name: String = ""

    var onNext: (String) -> Void

    var body: some View {
        VStack(spacing: 24) {
            ProgressBar(progress: 0.5)
                .frame(height: 8)
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 16) {
TypewriterText(
                    text: "what should we call you",
                    charInterval: 0.1,
                    color: .nudgeGreen900,
                    hapticStyle: .medium
                ) {
                    withAnimation(.easeIn(duration: 0.3)) { showControls = true }
                }

                if showControls {
                    VStack(alignment: .leading, spacing: 16) {
                        TextField("Your name", text: $name)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .foregroundStyle(Color.nudgeGreen900)
                            .tint(.nudgeGreen900)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.nudgeGreen900, lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.nudgeGreen900.opacity(0.05))
                                    )
                            )

                        Button("Next") {
                            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            onNext(trimmed)
                        }
                        .buttonStyle(NavPillStyle(variant: .primary))
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
    }
}

