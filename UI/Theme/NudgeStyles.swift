// UI/Theme/NudgeStyles.swift
import SwiftUI

// MARK: - Pill Variant
public enum PillVariant { 
    case primary, cyan, amber, accent, outline, neutral 
}

// MARK: - NavPillStyle
public struct NavPillStyle: ButtonStyle {
    var variant: PillVariant = .neutral
    var compact: Bool = false
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(compact ? .footnote.bold() : .callout.bold())
            .foregroundColor(foregroundColor)
            .padding(.horizontal, compact ? 10 : 14)
            .padding(.vertical, compact ? 6 : 8)
            .background(
                Capsule()
                    .fill(bgColor)
            )
            .shadow(color: shadowColor, radius: 0, x: 0, y: 3)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
    
    private var bgColor: Color {
        switch variant {
        case .primary: return Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87))
        case .cyan: return Color("NudgeCyanSurface", bundle: .main, default: Color(red: 0.81, green: 0.98, blue: 1.0))
        case .amber: return Color("NudgeAmberSurface", bundle: .main, default: Color(red: 1.0, green: 0.95, blue: 0.78))
        case .accent: return Color("NudgeAccentSurface", bundle: .main, default: Color(red: 0.86, green: 0.99, blue: 0.91))
        case .outline, .neutral: return Color(.systemBackground)
        }
    }
    
    private var borderColor: Color {
        switch variant {
        case .primary: return Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
        case .cyan: return Color("NudgeCyan600", bundle: .main, default: Color(red: 0.03, green: 0.57, blue: 0.70))
        case .amber: return Color("NudgeAmber600", bundle: .main, default: Color(red: 0.85, green: 0.46, blue: 0.02))
        case .accent: return Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
        case .outline, .neutral: return Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
        }
    }
    
    private var foregroundColor: Color {
        Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
    }
    
    private var shadowColor: Color {
        switch variant {
        case .primary: return Color(red: 0.0, green: 0.20, blue: 0.16)
        case .cyan: return Color("NudgeCyan600", bundle: .main, default: Color(red: 0.03, green: 0.57, blue: 0.70))
        case .amber: return Color("NudgeAmber600", bundle: .main, default: Color(red: 0.85, green: 0.46, blue: 0.02))
        case .accent, .outline, .neutral: return Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
        }
    }
}

// MARK: - RetroConsoleSurface
public struct RetroConsoleSurface: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96)))
            )
            .shadow(color: Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)), radius: 0, x: 0, y: 4)
            .shadow(color: Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)).opacity(0.2), radius: 12, x: 0, y: 4)
    }
}

public extension View {
    func retroConsoleSurface() -> some View { 
        self.modifier(RetroConsoleSurface()) 
    }
}

// MARK: - Color Extensions
public extension Color {
    static var nudgeGreen900: Color { 
        Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
    }
    
    init(_ name: String, bundle: Bundle, default fallback: Color) {
        if let _ = UIColor(named: name, in: bundle, compatibleWith: nil) {
            self = Color(name, bundle: bundle)
        } else {
            self = fallback
        }
    }
}