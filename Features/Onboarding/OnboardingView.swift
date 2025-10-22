import SwiftUI
import UIKit

// MARK: - Notifications for actions
extension Notification.Name {
    static let onboardingDismiss = Notification.Name("OnboardingDismiss")
    static let onboardingTakeTest = Notification.Name("OnboardingTakeTest")
}

struct OnboardingView: View {
    // Steps: Name -> Greeting -> Choice
    private enum Step { case name, greeting, choice }
    
    @State private var step: Step = .name
    @State private var name: String = ""
    @State private var showControls = false
@State private var showNext = false
@SwiftUI.FocusState private var nameFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Progress Bar
            ProgressBarInline(progress: progress)
                .frame(height: 8)
                .padding(.top, 12)
                .padding(.horizontal, 20)
            
            Group {
                switch step {
case .name:
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        VStack(alignment: .center, spacing: 16) {
                            // Centered prompt
                            TypewriterLine(
                                text: "what should we call you",
                                charInterval: 0.05,
                                color: .nudgeGreen900,
                                impactStyle: .medium
                            ) {
                                withAnimation(.easeIn(duration: 0.3)) { showControls = true }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            if showControls {
                                VStack(alignment: .center, spacing: 16) {
                                    TextField("Your name", text: $name)
                                        .focused($nameFieldFocused)
                                        .textInputAutocapitalization(.words)
                                        .disableAutocorrection(true)
                                        .foregroundStyle(Color.nudgeGreen900)
                                        .tint(.nudgeGreen900)
                                        .padding(14)
                                        .retroConsoleSurface()
                                        .frame(maxWidth: .infinity)
                                }
                                .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, 20)
                        Spacer(minLength: 0)
                    }
.onChange(of: showControls) { _, visible in
                        if visible {
                            DispatchQueue.main.async { nameFieldFocused = true }
                        }
                    }
                case .greeting:
                    VStack(alignment: .leading, spacing: 16) {
                        TypewriterLine(
text: "\(name), we’re so glad you’re here.",
                            charInterval: 0.05,
                            color: .nudgeGreen900,
                            impactStyle: .medium
                        ) {
                            withAnimation(.easeIn(duration: 0.3)) { showNext = true }
                        }
                        
                        if showNext {
                        }
                    }
                    .padding(.horizontal, 20)
case .choice:
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        VStack(spacing: 16) {
                            BigBoxButton(
                                title: "Take MBTI Test",
                                bgColor: Color("NudgeCyanSurface", bundle: .main, default: Color(red: 0.81, green: 0.98, blue: 1.0)),
                                borderColor: Color("NudgeCyan600", bundle: .main, default: Color(red: 0.03, green: 0.57, blue: 0.70))
                            ) {
                                NotificationCenter.default.post(name: .onboardingTakeTest, object: nil)
                            }
                            
                            BigBoxButton(
                                title: "Start Blocking Now",
                                bgColor: Color("NudgeAmberSurface", bundle: .main, default: Color(red: 1.0, green: 0.95, blue: 0.78)),
                                borderColor: Color("NudgeAmber600", bundle: .main, default: Color(red: 0.85, green: 0.46, blue: 0.02))
                            ) {
                                NotificationCenter.default.post(name: .onboardingDismiss, object: nil)
                            }
                        }
                        .padding(.horizontal, 20)
                        Spacer(minLength: 0)
                    }
                }
            }
Spacer()
        }
        .safeAreaInset(edge: .bottom) {
if bottomCTAVisible {
                Button(action: bottomCTAAction) {
                    HStack { Spacer(); Text("Next").font(.headline); Spacer() }
                }
                .buttonStyle(NavPillStyle(variant: .primary))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .disabled(!bottomCTAEnabled)
            }
        }
    }
    
    private var progress: CGFloat {
        switch step {
        case .name: return 0.5
        case .greeting: return 1.0
        case .choice: return 1.0
        }
    }
    
    private var bottomCTAVisible: Bool {
        switch step {
        case .name: return showControls
        case .greeting: return showNext
        case .choice: return false
        }
    }
    
    private var bottomCTAEnabled: Bool {
        switch step {
        case .name: return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .greeting: return true
        case .choice: return false
        }
    }
    
    private func bottomCTAAction() {
        switch step {
        case .name:
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            name = trimmed
            showControls = false
            withAnimation(.easeInOut) { step = .greeting }
        case .greeting:
            withAnimation(.easeInOut) { step = .choice }
        case .choice:
            break
        }
    }
}

// MARK: - Inline Progress Bar
private struct ProgressBarInline: View {
    var progress: CGFloat // 0...1
    var color: Color = .nudgeGreen900
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(color.opacity(0.15))
                Capsule().fill(color)
                    .frame(width: max(0, min(1, progress)) * geo.size.width)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Typewriter Line with Haptics and Caret
private struct TypewriterLine: View {
    let text: String
    let charInterval: TimeInterval
    let color: Color
    let impactStyle: UIImpactFeedbackGenerator.FeedbackStyle
    var onFinished: (() -> Void)? = nil
    
    @State private var visible = ""
    @State private var showCaret = true
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(visible)
                .foregroundStyle(color)
                .font(.title).fontWeight(.semibold)
                .animation(nil, value: visible)
            if showCaret {
Rectangle()
                    .fill(color)
                    .frame(width: 5, height: 24)
                    .opacity(1.0)
                    .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: showCaret)
            }
        }
        .onAppear(perform: startTyping)
    }
    
    private func startTyping() {
        visible = ""
        showCaret = true
        guard !text.isEmpty else {
            showCaret = false
            onFinished?()
            return
        }
        Task { @MainActor in
            let generator = UIImpactFeedbackGenerator(style: impactStyle)
            generator.prepare()
            for ch in text {
                try? await Task.sleep(nanoseconds: UInt64(charInterval * 1_000_000_000))
                visible.append(ch)
                generator.impactOccurred()
            }
            showCaret = false
            onFinished?()
        }
    }
}

#Preview {
    OnboardingView()
}

// MARK: - Big Choice Box Button
private struct BigBoxButton: View {
    let title: String
    let bgColor: Color
    let borderColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.title3).bold()
                    .foregroundStyle(Color.nudgeGreen900)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(Color.nudgeGreen900)
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 110)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(bgColor)
                    .shadow(color: borderColor, radius: 0, x: 0, y: 4)
                    .shadow(color: borderColor.opacity(0.2), radius: 12, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
    }
}
