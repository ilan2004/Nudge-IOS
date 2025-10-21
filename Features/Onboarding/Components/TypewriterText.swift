import SwiftUI
import UIKit

struct TypewriterText: View {
    let text: String
    let charInterval: TimeInterval
    let color: Color
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    var onFinished: (() -> Void)? = nil

    @State private var visible = ""
    @State private var index = 0
    @State private var showCaret = true

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(visible)
                .foregroundStyle(color)
                .font(.title).fontWeight(.semibold)
                .textCase(.none)
                .animation(nil, value: visible)

            // Thick blinking caret while typing
            if showCaret {
                Rectangle()
                    .fill(color)
                    .frame(width: 3, height: 24)
                    .opacity(caretOpacity)
                    .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: caretOpacity)
            }
        }
        .onAppear(perform: startTyping)
    }

    private var caretOpacity: Double { showCaret ? 1.0 : 0.0 }

    private func startTyping() {
        visible = ""
        index = 0
        showCaret = true

        guard !text.isEmpty else {
            showCaret = false
            onFinished?()
            return
        }

        Task { @MainActor in
            for ch in text {
                try? await Task.sleep(nanoseconds: UInt64(charInterval * 1_000_000_000))
                visible.append(ch)
                HapticsService.shared.impact(hapticStyle)
                index += 1
            }
            showCaret = false
            onFinished?()
        }
    }
}

