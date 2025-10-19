import SwiftUI

// Nudge style system approximating the web nav-pill and retro console surface
public enum PillVariant { case primary, cyan, amber, accent, outline, neutral }

public struct NavPillStyle: ButtonStyle {
    var variant: PillVariant = .neutral
    var compact: Bool = false

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(compact ? .footnote.bold() : .callout.bold())
            .padding(.horizontal, compact ? 10 : 14)
            .padding(.vertical, compact ? 6 : 8)
            .background(background(configuration: configuration))
            .overlay(
                Capsule().stroke(borderColor.opacity(1.0), lineWidth: 2)
            )
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
            .shadow(color: shadowColor.opacity(1.0), radius: 0, x: 0, y: 4)
    }

    private var bgColor: Color {
        switch variant {
        case .primary: return Color("NudgeGreenSurface", bundle: .main).opacity(1)
        case .cyan: return Color("NudgeCyanSurface", bundle: .main).opacity(1)
        case .amber: return Color("NudgeAmberSurface", bundle: .main).opacity(1)
        case .accent: return Color("NudgeAccentSurface", bundle: .main).opacity(1)
        case .outline, .neutral: return Color(.systemBackground)
        }
    }

    private var borderColor: Color {
        switch variant {
        case .primary: return Color("NudgeGreen900", bundle: .main)
        case .cyan: return Color("NudgeCyan600", bundle: .main)
        case .amber: return Color("NudgeAmber600", bundle: .main)
        case .accent: return Color("NudgeGreen900", bundle: .main)
        case .outline, .neutral: return Color("NudgeGreen900", bundle: .main)
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary, .cyan, .amber, .accent: return Color("NudgeGreen900", bundle: .main)
        case .outline, .neutral: return Color("NudgeGreen900", bundle: .main)
        }
    }

    private var shadowColor: Color { Color("NudgeGreen900", bundle: .main) }

    @ViewBuilder
    private func background(configuration: Configuration) -> some View {
        Capsule()
            .fill( variant == .outline || variant == .neutral ? Color(.systemBackground) : bgColor )
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: 2)
            )
            .shadow(color: shadowColor.opacity(1.0), radius: 0, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

public struct RetroConsoleSurface: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(
                Capsule()
                    .fill(Color("NudgeSurface", bundle: .main))
            )
            .overlay(
                Capsule().stroke(Color("NudgeGreen900", bundle: .main), lineWidth: 2)
            )
            .shadow(color: Color("NudgeGreen900", bundle: .main), radius: 0, x: 0, y: 4)
            .shadow(color: Color("NudgeGreen900", bundle: .main).opacity(0.2), radius: 24, x: 0, y: 8)
    }
}

public extension View {
    func retroConsoleSurface() -> some View { self.modifier(RetroConsoleSurface()) }
}

// Provide default color assets if not present by falling back to RGB values
public extension Color {
    static var nudgeGreen900: Color { Color("NudgeGreen900", bundle: .main, default: Color(red: 3/255, green: 89/255, blue: 77/255)) }
}

private extension Color {
    init(_ name: String, bundle: Bundle, default fallback: Color) {
        if let _ = UIColor(named: name, in: bundle, compatibleWith: nil) { self = Color(name) } else { self = fallback }
    }
}

