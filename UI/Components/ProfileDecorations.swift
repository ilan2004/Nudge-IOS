import SwiftUI

// UI/Components/ProfileDecorations.swift
// Reusable decorative elements for profile components with personality-aware theming

// MARK: - DecorativeCorner
struct DecorativeCorner: View {
    enum Position { case topLeft, topRight, bottomLeft, bottomRight }
    let position: Position
    let theme: PersonalityColors
    let size: CGFloat
    let lineWidth: CGFloat
    @State private var pulse = false
    
    init(position: Position, theme: PersonalityColors, size: CGFloat = 14, lineWidth: CGFloat = 1) {
        self.position = position
        self.theme = theme
        self.size = size
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(theme.secondary.opacity(0.5), lineWidth: lineWidth)
                .frame(width: size, height: size)
            Circle()
                .fill(theme.primary.opacity(0.08))
                .frame(width: size * 0.66, height: size * 0.66)
                .scaleEffect(pulse ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
        }
        .rotationEffect(rotation)
        .offset(offset)
        .onAppear { pulse = true }
        .accessibilityHidden(true)
    }
    
    private var rotation: Angle {
        switch position {
        case .topLeft: return .degrees(0)
        case .topRight: return .degrees(90)
        case .bottomLeft: return .degrees(270)
        case .bottomRight: return .degrees(180)
        }
    }
    private var offset: CGSize {
        switch position {
        case .topLeft: return .init(width: -6, height: -6)
        case .topRight: return .init(width: 6, height: -6)
        case .bottomLeft: return .init(width: -6, height: 6)
        case .bottomRight: return .init(width: 6, height: 6)
        }
    }
}

// MARK: - StatDivider (RPG-style)
struct StatDivider: View {
    let theme: PersonalityColors
    let tint: Color
    init(theme: PersonalityColors, tint: Color? = nil) {
        self.theme = theme
        self.tint = tint ?? theme.secondary
    }
    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 1).fill(tint.opacity(0.25)).frame(height: 1)
            RoundedRectangle(cornerRadius: 2)
                .fill(tint.opacity(0.5))
                .frame(width: 8, height: 4)
                .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.white.opacity(0.35), lineWidth: 0.5))
            RoundedRectangle(cornerRadius: 1).fill(tint.opacity(0.25)).frame(height: 1)
        }
        .frame(height: 6)
        .accessibilityHidden(true)
    }
}

// MARK: - CurrencyGlow
struct CurrencyGlow: View {
    let color: Color
    let size: CGFloat
    @State private var animate = false
    init(color: Color, size: CGFloat = 80) {
        self.color = color
        self.size = size
    }
    var body: some View {
        RadialGradient(colors: [color.opacity(0.35), .clear], center: .center, startRadius: 2, endRadius: size)
            .scaleEffect(animate ? 1.05 : 0.95)
            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: animate)
            .onAppear { animate = true }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

// MARK: - RankBadge
struct RankBadge: View {
    enum Medal { case gold, silver, bronze, standard(Color) }
    let rank: Int
    let medal: Medal
    let theme: PersonalityColors
    
    init(rank: Int, theme: PersonalityColors) {
        self.rank = rank
        self.theme = theme
        self.medal = RankBadge.medal(for: rank, theme: theme)
    }
    
    var body: some View {
        let medColor = color(for: medal)
        return ZStack {
            Circle()
                .fill(LinearGradient(colors: [medColor.opacity(0.95), medColor.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: medColor.opacity(0.4), radius: 10)
            Text("#\(rank)")
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(.white)
        }
        .frame(width: 48, height: 48)
        .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 1))
        .overlay(
            HStack(spacing: 2) {
                if rank <= 3 { Image(systemName: "crown.fill") }
            }
            .font(.caption2.bold())
            .foregroundColor(.white)
            .padding(4)
            , alignment: .topTrailing
        )
        .accessibilityLabel(Text("Rank \(rank)"))
    }
    
    static func medal(for rank: Int, theme: PersonalityColors) -> Medal {
        switch rank {
        case 1...3: return .gold
        case 4...10: return .silver
        case 11...50: return .bronze
        default: return .standard(theme.secondary)
        }
    }
    private func color(for medal: Medal) -> Color {
        switch medal {
        case .gold: return .yellow
        case .silver: return .gray
        case .bronze: return Color.orange
        case .standard(let c): return c
        }
    }
}

// MARK: - AchievementFrame
struct AchievementFrame: View {
    enum Rarity { case common, silver, gold, legendary }
    let title: String
    let unlocked: Bool
    let rarity: Rarity
    let theme: PersonalityColors
    @State private var appear = false
    
    init(title: String, unlocked: Bool, rarity: Rarity, theme: PersonalityColors) {
        self.title = title
        self.unlocked = unlocked
        self.rarity = rarity
        self.theme = theme
    }
    
    var body: some View {
        let border = borderColor
        return VStack(spacing: 8) {
            Image(systemName: unlocked ? "trophy.fill" : "lock.fill")
                .font(.title2)
                .foregroundColor(unlocked ? border : theme.secondary)
                .shadow(color: unlocked ? border.opacity(0.5) : .clear, radius: 8)
            Text(title)
                .font(.caption)
                .foregroundColor(theme.text)
                .multilineTextAlignment(.center)
        }
        .frame(width: 120, height: 100)
        .background(RoundedRectangle(cornerRadius: 12).fill(theme.surface.opacity(0.95)))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(border.opacity(unlocked ? 0.9 : 0.4), lineWidth: unlocked ? 2 : 1)
        )
        .overlay(
            RadialGradient(colors: [Color.white.opacity(unlocked ? 0.35 : 0.0), .clear], center: .top, startRadius: 8, endRadius: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        )
        .scaleEffect(appear ? 1.0 : 0.9)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: appear)
        .onAppear { appear = true }
    }
    
    private var borderColor: Color {
        switch rarity {
        case .common: return theme.secondary
        case .silver: return .gray
        case .gold: return .yellow
        case .legendary: return .pink
        }
    }
}

// MARK: - ShieldIcon
struct ShieldIcon: View {
    let primary: Color
    let secondary: Color
    let overlayIcon: String?
    init(primary: Color, secondary: Color, overlayIcon: String? = nil) {
        self.primary = primary
        self.secondary = secondary
        self.overlayIcon = overlayIcon
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient(colors: [secondary.opacity(0.15), .clear], startPoint: .top, endPoint: .bottom))
                .frame(width: 36, height: 44)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(secondary.opacity(0.5), lineWidth: 1))
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 28))
                .foregroundColor(primary)
                .shadow(color: primary.opacity(0.4), radius: 6)
            if let icon = overlayIcon {
                Image(systemName: icon)
                    .font(.caption2.bold())
                    .foregroundColor(.red)
                    .offset(x: 8, y: 10)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - LevelIndicator
struct LevelIndicator: View {
    let hours: Double
    let theme: PersonalityColors
    init(hours: Double, theme: PersonalityColors) {
        self.hours = hours
        self.theme = theme
    }
    private var level: Int { max(1, Int(hours / 10.0) + 1) }
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill").foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.6), radius: 6)
            Text("Lv \(level)")
                .font(.custom("Tanker-Regular", size: 14))
                .foregroundColor(theme.text)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(theme.primary.opacity(0.25)))
        .overlay(Capsule().stroke(theme.secondary.opacity(0.4), lineWidth: 1))
    }
}

// MARK: - PersonalityAccentBar
struct PersonalityAccentBar: View {
    let theme: PersonalityColors
    let height: CGFloat
    init(theme: PersonalityColors, height: CGFloat = 6) {
        self.theme = theme
        self.height = height
    }
    var body: some View {
        LinearGradient(colors: [theme.primary.opacity(0.5), theme.accent.opacity(0.4)], startPoint: .leading, endPoint: .trailing)
            .frame(height: height)
            .overlay(Rectangle().fill(Color.white.opacity(0.25)).frame(height: 1), alignment: .top)
            .accessibilityHidden(true)
    }
}

// MARK: - StatIcon
struct StatIcon: View {
    let systemName: String
    let theme: PersonalityColors
    let size: CGFloat
    init(systemName: String, theme: PersonalityColors, size: CGFloat = 28) {
        self.systemName = systemName
        self.theme = theme
        self.size = size
    }
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [theme.primary.opacity(0.25), theme.accent.opacity(0.15)], startPoint: .top, endPoint: .bottom))
            Image(systemName: systemName)
                .font(.system(size: size * 0.55, weight: .semibold))
                .foregroundColor(theme.secondary)
        }
        .frame(width: size, height: size)
        .overlay(Circle().stroke(theme.secondary.opacity(0.3), lineWidth: 1))
        .shadow(color: theme.secondary.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

// MARK: - SettingsDivider
struct SettingsDivider: View {
    let theme: PersonalityColors
    init(theme: PersonalityColors) { self.theme = theme }
    var body: some View {
        Rectangle()
            .fill(LinearGradient(colors: [theme.secondary.opacity(0.15), .clear], startPoint: .leading, endPoint: .trailing))
            .frame(height: 1)
            .overlay(Rectangle().fill(.white.opacity(0.15)).frame(height: 0.5), alignment: .top)
            .accessibilityHidden(true)
    }
}

