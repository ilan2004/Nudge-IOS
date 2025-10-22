import SwiftUI

// MARK: - 1) ParchmentTexture
public struct ParchmentTexture: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.02),
                        Color.black.opacity(0.01),
                        Color.white.opacity(0.015),
                        Color.black.opacity(0.008)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.overlay)
            )
    }
}

// MARK: - 2) GuildCardColors
public extension Color {
    // Parchment/Paper
    static let guildParchment = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let guildParchmentDark = Color(red: 0.90, green: 0.85, blue: 0.75)

    // Dark Brown/Charcoal (borders, text)
    static let guildBrown = Color(red: 0.25, green: 0.20, blue: 0.15)
    static let guildBrownLight = Color(red: 0.45, green: 0.38, blue: 0.30)

    // Text
    static let guildText = Color(red: 0.20, green: 0.15, blue: 0.12)
    static let guildTextSecondary = Color(red: 0.40, green: 0.35, blue: 0.30)

    // Aged Gold/Bronze (seals, stamps)
    static let guildGold = Color(red: 0.85, green: 0.75, blue: 0.60)
    static let guildGoldDark = Color(red: 0.60, green: 0.45, blue: 0.25)
}

// MARK: - 3) CornerReinforcement
public struct CornerReinforcement: View {
    public enum Corner { case topLeft, topRight, bottomLeft, bottomRight }
    public let corner: Corner
    public let size: CGFloat = 12
    public let thickness: CGFloat = 2

    public init(corner: Corner) { self.corner = corner }

    public var body: some View {
        Path { path in
            // Draw L-shaped bracket (origin at top-left of frame)
            path.move(to: CGPoint(x: 0, y: size))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: size, y: 0))
        }
        .stroke(Color.guildBrown, lineWidth: thickness)
        .rotationEffect(rotation, anchor: .topLeading)
        .frame(width: size, height: size)
    }

    private var rotation: Angle {
        switch corner {
        case .topLeft: return .degrees(0)
        case .topRight: return .degrees(90)
        case .bottomRight: return .degrees(180)
        case .bottomLeft: return .degrees(270)
        }
    }
}

// MARK: - 4) GuildSeal
public struct GuildSeal: View {
    public let level: Int
    public init(level: Int) { self.level = level }

    public var body: some View {
        ZStack {
            // Seal background
            Circle()
                .fill(Color.guildGold)
                .frame(width: 50, height: 50)

            // Border
            Circle()
                .stroke(Color.guildBrown, lineWidth: 2)
                .frame(width: 50, height: 50)

            // Inner decorative circle
            Circle()
                .stroke(Color.guildBrownLight, lineWidth: 1)
                .frame(width: 42, height: 42)

            // Content
            VStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .foregroundColor(Color.guildGoldDark)
                    .font(.caption)
                Text("Lv \(level)")
                    .font(.custom("Tanker-Regular", size: 11))
                    .foregroundColor(Color.guildText)
            }
        }
        .shadow(color: Color.guildBrown.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 5) DottedSeparator
public struct DottedSeparator: View {
    public init() {}
    public var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 1.5)
            .overlay(
                Rectangle()
                    .stroke(
                        style: StrokeStyle(lineWidth: 1.5, dash: [3, 3])
                    )
                    .foregroundColor(Color.guildBrownLight)
            )
    }
}

// MARK: - 6) View Extensions
public extension View {
    func parchmentTexture() -> some View {
        self.modifier(ParchmentTexture())
    }
}

