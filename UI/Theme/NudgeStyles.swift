// UI/Theme/NudgeStyles.swift
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Pill Variant
public enum PillVariant { 
    case primary, cyan, amber, accent, outline, neutral, danger 
}

// MARK: - NavPillStyle
public struct NavPillStyle: ButtonStyle {
    var variant: PillVariant = .neutral
    var compact: Bool = false
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(compact ? .footnote.bold() : .callout.bold())
            .padding(.horizontal, compact ? 10 : 14)
            .padding(.vertical, compact ? 6 : 8)
            .background(
                Capsule()
                    .fill(bgColor)
                    .shadow(color: shouldHaveShadow ? shadowColor : .clear, radius: 0, x: 0, y: 4)
                    .shadow(color: shouldHaveShadow ? shadowColor.opacity(0.2) : .clear, radius: 12, x: 0, y: 8)
            )
            .foregroundStyle(foregroundColor)
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
    
    private var shouldHaveShadow: Bool {
        switch variant {
        case .primary, .cyan, .amber, .accent, .danger:
            return true
        case .outline, .neutral:
            return false
        }
    }
    
    private var bgColor: Color {
        switch variant {
        case .primary: return Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87))
        case .cyan: return Color("NudgeCyanSurface", bundle: .main, default: Color(red: 0.81, green: 0.98, blue: 1.0))
        case .amber: return Color("NudgeAmberSurface", bundle: .main, default: Color(red: 1.0, green: 0.95, blue: 0.78))
        case .accent: return Color("NudgeAccentSurface", bundle: .main, default: Color(red: 0.86, green: 0.99, blue: 0.91))
        case .danger: return Color("NudgeRedSurface", bundle: .main, default: Color(red: 1.0, green: 0.92, blue: 0.92))
        case .outline, .neutral: return Color(.systemBackground)
        }
    }
    
    private var borderColor: Color {
        switch variant {
        case .primary: return Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
        case .cyan: return Color("NudgeCyan600", bundle: .main, default: Color(red: 0.03, green: 0.57, blue: 0.70))
        case .amber: return Color("NudgeAmber600", bundle: .main, default: Color(red: 0.85, green: 0.46, blue: 0.02))
        case .accent: return Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
        case .danger: return Color("NudgeRed700", bundle: .main, default: Color(red: 0.75, green: 0.20, blue: 0.20))
        case .outline, .neutral: return Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
        }
    }
    
    private var foregroundColor: Color {
        Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
    }
    
    private var shadowColor: Color {
        switch variant {
        case .primary: return Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
        case .cyan: return Color("NudgeCyan600", bundle: .main, default: Color(red: 0.03, green: 0.57, blue: 0.70))
        case .amber: return Color("NudgeAmber600", bundle: .main, default: Color(red: 0.85, green: 0.46, blue: 0.02))
        case .accent: return Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
        case .danger: return Color("NudgeRed700", bundle: .main, default: Color(red: 0.75, green: 0.20, blue: 0.20))
        case .outline, .neutral: return Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30))
        }
    }
}

// MARK: - RetroConsoleSurface
public struct RetroConsoleSurface: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(.clear)  
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96)))
                    .shadow(color: Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)), radius: 0, x: 0, y: 4)
                    .shadow(color: Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)).opacity(0.2), radius: 12, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)), lineWidth: 2)
            )
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

// MARK: - Decorative Helpers
private struct OrnateCorner: View {
    enum Corner { case topLeft, topRight, bottomLeft, bottomRight }
    let corner: Corner
    let color: Color
    let size: CGFloat
    var body: some View {
        ZStack {
            Circle().stroke(color.opacity(0.5), lineWidth: 1)
                .frame(width: size, height: size)
            Circle().fill(color.opacity(0.08))
                .frame(width: size * 0.66, height: size * 0.66)
        }
        .rotationEffect(angle)
        .offset(offset)
        .accessibilityHidden(true)
    }
    private var angle: Angle {
        switch corner { case .topLeft: return .degrees(0); case .topRight: return .degrees(90); case .bottomLeft: return .degrees(270); case .bottomRight: return .degrees(180) }
    }
    private var offset: CGSize {
        switch corner {
        case .topLeft: return .init(width: -6, height: -6)
        case .topRight: return .init(width: 6, height: -6)
        case .bottomLeft: return .init(width: -6, height: 6)
        case .bottomRight: return .init(width: 6, height: 6)
        }
    }
}

// MARK: - HeroCard Helpers
private struct PaperTextureOverlay: View {
    var body: some View {
        Group {
#if canImport(UIKit)
            if let uiImage = UIImage(named: "PaperTexture", in: .main, compatibleWith: nil) ?? UIImage(named: "PaperNoise", in: .main, compatibleWith: nil) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.08)
                    .blendMode(.multiply)
            } else {
                GrainFallback()
            }
#else
            GrainFallback()
#endif
        }
    }
    private struct GrainFallback: View {
        var body: some View {
            GeometryReader { geo in
                let step: CGFloat = 6
                Path { path in
                    var y: CGFloat = 0
                    while y < geo.size.height {
                        var x: CGFloat = 0
                        while x < geo.size.width {
                            path.addEllipse(in: CGRect(x: x, y: y, width: 1, height: 1))
                            x += step
                        }
                        y += step
                    }
                }
                .fill(Color.black.opacity(0.03))
                .blendMode(.multiply)
            }
        }
    }
}

private struct CornerBrackets: View {
    let color: Color
    let length: CGFloat
    let lineWidth: CGFloat
    let inset: CGFloat
    let cornerRadius: CGFloat
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // Top-left L
                Path { p in
                    p.move(to: CGPoint(x: inset, y: inset + length))
                    p.addLine(to: CGPoint(x: inset, y: inset))
                    p.addLine(to: CGPoint(x: inset + length, y: inset))
                }.stroke(color, lineWidth: lineWidth)
                // Top-right L
                Path { p in
                    p.move(to: CGPoint(x: w - inset - length, y: inset))
                    p.addLine(to: CGPoint(x: w - inset, y: inset))
                    p.addLine(to: CGPoint(x: w - inset, y: inset + length))
                }.stroke(color, lineWidth: lineWidth)
                // Bottom-left L
                Path { p in
                    p.move(to: CGPoint(x: inset, y: h - inset - length))
                    p.addLine(to: CGPoint(x: inset, y: h - inset))
                    p.addLine(to: CGPoint(x: inset + length, y: h - inset))
                }.stroke(color, lineWidth: lineWidth)
                // Bottom-right L
                Path { p in
                    p.move(to: CGPoint(x: w - inset - length, y: h - inset))
                    p.addLine(to: CGPoint(x: w - inset, y: h - inset))
                    p.addLine(to: CGPoint(x: w - inset, y: h - inset - length))
                }.stroke(color, lineWidth: lineWidth)
            }
        }
    }
}

// MARK: - HeroCardSurface
public struct HeroCardSurface: ViewModifier {
    public func body(content: Content) -> some View {
        let parchment = Color(red: 0.98, green: 0.96, blue: 0.92)
        let darkBrown = Color(red: 0.25, green: 0.20, blue: 0.15)
        let lightBrown = Color(red: 0.45, green: 0.38, blue: 0.30)
        let stampBg = Color(red: 0.85, green: 0.75, blue: 0.60)
        let textColor = Color(red: 0.20, green: 0.15, blue: 0.12)
        return content
            .foregroundStyle(textColor)
            .padding(14)
            .background(
                ZStack {
                    // Base parchment background with subtle grain and vignette
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(parchment)
                        .overlay(PaperTextureOverlay().clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous)))
                        .shadow(color: darkBrown, radius: 0, x: 0, y: 4)
                        .shadow(color: darkBrown.opacity(0.2), radius: 12, x: 0, y: 8)
                    // Thick rustic border
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(darkBrown, lineWidth: 3)
                    // Inner dotted border
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .inset(by: 10)
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                        .foregroundStyle(lightBrown)
                    // Optional corner reinforcements
                    CornerBrackets(color: darkBrown, length: 10, lineWidth: 2, inset: 6, cornerRadius: 14)
                        .allowsHitTesting(false)
                    // Horizontal dotted separator below portrait area
                    VStack { 
                        Spacer().frame(height: 88)
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 1)
                            .overlay(
                                Rectangle()
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3,3]))
                                    .foregroundStyle(lightBrown)
                            )
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .allowsHitTesting(false)
                    // Guild seal / level stamp placeholder (top-right)
                    Circle()
                        .fill(stampBg.opacity(0.25))
                        .frame(width: 36, height: 36)
                        .overlay(Circle().stroke(darkBrown.opacity(0.6), lineWidth: 2))
                        .overlay(
                            Text("✦")
                                .font(.system(size: 12, weight: .bold, design: .serif))
                                .foregroundStyle(darkBrown.opacity(0.6))
                        )
                        .shadow(color: darkBrown.opacity(0.2), radius: 1, x: 0, y: 1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(8)
                        .allowsHitTesting(false)
                    // Watermark text
                    Text("GUILD REGISTRY")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundStyle(lightBrown.opacity(0.08))
                        .rotationEffect(.degrees(-10))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .allowsHitTesting(false)
                    // Subtle vignette to age edges
                    RadialGradient(colors: [.clear, darkBrown.opacity(0.06)], center: .center, startRadius: 180, endRadius: 600)
                        .blendMode(.multiply)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .allowsHitTesting(false)
                }
            )
    }
}

// MARK: - StatsPanelSurface
public struct StatsPanelSurface: ViewModifier {
    @EnvironmentObject private var personalityManager: PersonalityManager
    public func body(content: Content) -> some View {
        let theme = personalityManager.currentTheme
        return content
            .padding(12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96)))
                        // Inset effect (top highlight + bottom shadow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(LinearGradient(colors: [Color.white.opacity(0.7), Color.black.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        // Standard two-layer green shadow
                        .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                        .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                    // Grid-like decorative lines
                    GeometryReader { geo in
                        let step: CGFloat = max(24, min(40, min(geo.size.width, geo.size.height) / 6))
                        Path { path in
                            var x: CGFloat = step
                            while x < geo.size.width { path.move(to: CGPoint(x: x, y: 8)); path.addLine(to: CGPoint(x: x, y: geo.size.height - 8)); x += step }
                            var y: CGFloat = step
                            while y < geo.size.height { path.move(to: CGPoint(x: 8, y: y)); path.addLine(to: CGPoint(x: geo.size.width - 8, y: y)); y += step }
                        }
                        .stroke(theme.secondary.opacity(0.08), lineWidth: 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            )
    }
}

// MARK: - CurrencyVaultSurface
public struct CurrencyVaultSurface: ViewModifier {
    @EnvironmentObject private var personalityManager: PersonalityManager
    public func body(content: Content) -> some View {
        let theme = personalityManager.currentTheme
        return content
            .padding(14)
            .background(
                ZStack {
                    // Rich, metallic-inspired gradient (opaque)
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(colors: [
                                Color(red: 0.98, green: 0.93, blue: 0.78),
                                Color(red: 0.92, green: 0.80, blue: 0.52),
                                Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96))
                            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(LinearGradient(colors: [theme.secondary.opacity(0.7), theme.primary.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                        )
                        // Standard two-layer green shadow
                        .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                        .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                    // Coin-themed watermark
                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { idx in
                            Circle()
                                .fill(LinearGradient(colors: [Color.yellow.opacity(0.18), Color.orange.opacity(0.12)], startPoint: .top, endPoint: .bottom))
                                .frame(width: 18, height: 18)
                                .overlay(Circle().stroke(Color.orange.opacity(0.25), lineWidth: 1))
                                .offset(y: (idx % 2 == 0) ? -2 : 2)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(10)
                    .allowsHitTesting(false)
                }
            )
    }
}

// MARK: - AchievementShowcaseSurface
public struct AchievementShowcaseSurface: ViewModifier {
    @EnvironmentObject private var personalityManager: PersonalityManager
    public func body(content: Content) -> some View {
        let theme = personalityManager.currentTheme
        return content
            .padding(12)
            .background(
                ZStack {
                    // Solid base with glass-like overlays
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96)))
                        .overlay(
                            LinearGradient(colors: [Color.white.opacity(0.35), Color.white.opacity(0.15)], startPoint: .top, endPoint: .bottom)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(LinearGradient(colors: [theme.accent.opacity(0.9), theme.primary.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        // Standard two-layer green shadow
                        .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                        .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                    // Spotlight effect
                    RadialGradient(colors: [Color.white.opacity(0.35), .clear], center: .topLeading, startRadius: 8, endRadius: 180)
                        .blendMode(.screen)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .allowsHitTesting(false)
                }
            )
    }
}

// MARK: - LeaderboardRankSurface
public struct LeaderboardRankSurface: ViewModifier {
    @EnvironmentObject private var personalityManager: PersonalityManager
    let rank: Int
    public func body(content: Content) -> some View {
        let theme = personalityManager.currentTheme
        // Dynamic accent: top 3 get stronger color & glow
        let accent = rank <= 3 ? theme.primary : theme.secondary
        return content
            .padding(12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(accent.opacity(0.9), lineWidth: rank <= 3 ? 2 : 1)
                        )
                        // Standard two-layer green shadow
                        .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                        .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                    // Rank indicator chevrons
                    HStack(spacing: 4) {
                        ForEach(0..<min(rank, 5), id: \.self) { _ in
                            Capsule()
                                .fill(accent.opacity(0.25))
                                .frame(width: 8, height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(10)
                    .allowsHitTesting(false)
                }
            )
    }
}

// MARK: - ControlPanelSurface
public struct ControlPanelSurface: ViewModifier {
    @EnvironmentObject private var personalityManager: PersonalityManager
    public func body(content: Content) -> some View {
        let theme = personalityManager.currentTheme
        return content
            .padding(12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 3]))
                                .foregroundStyle(theme.secondary.opacity(0.8))
                        )
                        // Standard two-layer green shadow
                        .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                        .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                    // Toggle-knurl garnish
                    HStack(spacing: 4) {
                        ForEach(0..<10, id: \.self) { idx in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(theme.secondary.opacity(0.12))
                                .frame(width: 2, height: 8)
                                .rotationEffect(.degrees(8))
                                .offset(y: (idx % 2 == 0) ? -1 : 1)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(8)
                    .allowsHitTesting(false)
                }
            )
    }
}

// MARK: - BlockingShieldSurface
public struct BlockingShieldSurface: ViewModifier {
    @EnvironmentObject private var personalityManager: PersonalityManager
    public func body(content: Content) -> some View {
        let theme = personalityManager.currentTheme
        return content
            .padding(12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96)))
                        .overlay(
                            // Bold double border for defensive feel
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(theme.secondary.opacity(0.9), lineWidth: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .inset(by: 6)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                                .foregroundStyle(theme.primary.opacity(0.8))
                        )
                        // Standard two-layer green shadow
                        .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                        .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                    // Shield watermark
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 64, weight: .regular))
                        .foregroundColor(theme.secondary.opacity(0.08))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(10)
                        .allowsHitTesting(false)
                    // Diagonal safety stripes (very subtle)
                    LinearGradient(colors: [theme.secondary.opacity(0.05), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .blendMode(.multiply)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .allowsHitTesting(false)
                }
            )
    }
}

// MARK: - UndergroundModeSurface
public struct UndergroundModeSurface: ViewModifier {
    public func body(content: Content) -> some View {
        let baseDark = Color(red: 0.08, green: 0.08, blue: 0.12)
        let drop = Color(red: 0.15, green: 0.15, blue: 0.25)
        let borderOuter = Color(red: 0.25, green: 0.25, blue: 0.4)
        let borderGlow = Color(red: 0.4, green: 0.4, blue: 0.6).opacity(0.5)
        return content
            .foregroundStyle(Color.white.opacity(0.92))
            .padding(12)
            .background(
                ZStack {
                    // Solid dark background with dark shadows
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(baseDark)
                        .shadow(color: drop, radius: 0, x: 0, y: 4)
                        .shadow(color: drop.opacity(0.6), radius: 12, x: 0, y: 8)
                        .overlay(
                            // Outer border and inner glow
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(borderOuter, lineWidth: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .inset(by: 4)
                                .stroke(borderGlow, lineWidth: 1)
                        )
                    // Subtle diagonal dark gradient overlay
                    LinearGradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.05, green: 0.05, blue: 0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .allowsHitTesting(false)
                    // Watermark + stealth icons
                    ZStack {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 54))
                            .foregroundColor(Color.white.opacity(0.06))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(10)
                        Image(systemName: "eye.slash")
                            .font(.system(size: 28))
                            .foregroundColor(Color.white.opacity(0.08))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .padding(10)
                    }
                    .allowsHitTesting(false)
                    // Corner glow particles
                    ZStack {
                        ForEach(0..<8, id: \.self) { i in
                            Circle()
                                .fill((i % 2 == 0 ? Color.purple : Color.blue).opacity(0.08))
                                .frame(width: 6, height: 6)
                                .offset(x: i < 4 ? CGFloat(8 + i * 6) : CGFloat(-8 - (i-4) * 6), y: i % 3 == 0 ? -8 : 8)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(8)
                    .allowsHitTesting(false)
                    // Night sky subtle dots
                    GeometryReader { geo in
                        let step: CGFloat = 32
                        Path { path in
                            var y: CGFloat = 8
                            while y < geo.size.height { 
                                var x: CGFloat = 8
                                while x < geo.size.width {
                                    path.addEllipse(in: CGRect(x: x, y: y, width: 1, height: 1))
                                    x += step
                                }
                                y += step
                            }
                        }
                        .fill(Color.white.opacity(0.035))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .allowsHitTesting(false)
                    // Vignette effect
                    RadialGradient(colors: [Color.clear, Color.black.opacity(0.25)], center: .center, startRadius: 80, endRadius: 500)
                        .blendMode(.multiply)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .allowsHitTesting(false)
                }
            )
    }
}

// MARK: - View extension entry points
public extension View {
    func heroCardSurface() -> some View { self.modifier(HeroCardSurface()) }
    func statsPanelSurface() -> some View { self.modifier(StatsPanelSurface()) }
    func currencyVaultSurface() -> some View { self.modifier(CurrencyVaultSurface()) }
    func achievementShowcaseSurface() -> some View { self.modifier(AchievementShowcaseSurface()) }
    func leaderboardRankSurface(rank: Int) -> some View { self.modifier(LeaderboardRankSurface(rank: rank)) }
    func controlPanelSurface() -> some View { self.modifier(ControlPanelSurface()) }
    func blockingShieldSurface() -> some View { self.modifier(BlockingShieldSurface()) }
    func undergroundModeSurface() -> some View { self.modifier(UndergroundModeSurface()) }
}
