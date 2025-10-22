// UI/Theme/NudgeStyles.swift
import SwiftUI

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

// MARK: - HeroCardSurface
public struct HeroCardSurface: ViewModifier {
    @EnvironmentObject private var personalityManager: PersonalityManager
    public func body(content: Content) -> some View {
        let theme = personalityManager.currentTheme
        return content
            .padding(14)
            .background(
                ZStack {
                    // Subtle gradient background using personality colors
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(colors: [theme.surface, theme.background.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: theme.secondary.opacity(0.20), radius: 16, x: 0, y: 10)
                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 1)
                        .overlay(
                            // Double ornate border
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(theme.secondary.opacity(0.8), lineWidth: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .inset(by: 6)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 3]))
                                .foregroundStyle(theme.primary.opacity(0.9))
                        )
                    // Personality-colored accent strips
                    VStack(spacing: 0) {
                        LinearGradient(colors: [theme.primary.opacity(0.35), theme.accent.opacity(0.15)], startPoint: .leading, endPoint: .trailing)
                            .frame(height: 6)
                            .overlay(Rectangle().fill(.white.opacity(0.25)).frame(height: 1), alignment: .bottom)
                        Spacer()
                        LinearGradient(colors: [theme.accent.opacity(0.15), theme.primary.opacity(0.35)], startPoint: .leading, endPoint: .trailing)
                            .frame(height: 4)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    // Ornate corners
                    ZStack {
                        OrnateCorner(corner: .topLeft, color: theme.secondary, size: 14).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        OrnateCorner(corner: .topRight, color: theme.secondary, size: 14).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        OrnateCorner(corner: .bottomLeft, color: theme.secondary, size: 14).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        OrnateCorner(corner: .bottomRight, color: theme.secondary, size: 14).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
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
                        .fill(theme.surface)
                        // Inset effect (top highlight + bottom shadow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(LinearGradient(colors: [Color.white.opacity(0.7), Color.black.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        .shadow(color: theme.secondary.opacity(0.15), radius: 12, x: 0, y: 8)
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
                    // Rich, metallic-inspired gradient
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(colors: [
                                Color(red: 0.98, green: 0.93, blue: 0.78),
                                Color(red: 0.92, green: 0.80, blue: 0.52),
                                theme.surface
                            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(LinearGradient(colors: [theme.secondary.opacity(0.7), theme.primary.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                        )
                        .shadow(color: theme.secondary.opacity(0.25), radius: 14, x: 0, y: 10)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 1)
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
                    // Glass-like panel
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(colors: [theme.surface.opacity(0.85), Color.white.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                                .blur(radius: 0)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(LinearGradient(colors: [theme.accent.opacity(0.9), theme.primary.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
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
                        .fill(LinearGradient(colors: [theme.surface, theme.background.opacity(0.06)], startPoint: .top, endPoint: .bottom))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(accent.opacity(0.9), lineWidth: rank <= 3 ? 2 : 1)
                        )
                        .shadow(color: accent.opacity(rank <= 3 ? 0.25 : 0.12), radius: rank <= 3 ? 14 : 8, x: 0, y: rank <= 3 ? 10 : 6)
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
                        .fill(LinearGradient(colors: [theme.surface, theme.secondary.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 3]))
                                .foregroundStyle(theme.secondary.opacity(0.8))
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
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
                        .fill(
                            LinearGradient(colors: [theme.surface, theme.secondary.opacity(0.06)], startPoint: .top, endPoint: .bottom)
                        )
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
                        .shadow(color: theme.secondary.opacity(0.22), radius: 10, x: 0, y: 8)
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

// MARK: - View extension entry points
public extension View {
    func heroCardSurface() -> some View { self.modifier(HeroCardSurface()) }
    func statsPanelSurface() -> some View { self.modifier(StatsPanelSurface()) }
    func currencyVaultSurface() -> some View { self.modifier(CurrencyVaultSurface()) }
    func achievementShowcaseSurface() -> some View { self.modifier(AchievementShowcaseSurface()) }
    func leaderboardRankSurface(rank: Int) -> some View { self.modifier(LeaderboardRankSurface(rank: rank)) }
    func controlPanelSurface() -> some View { self.modifier(ControlPanelSurface()) }
    func blockingShieldSurface() -> some View { self.modifier(BlockingShieldSurface()) }
}
