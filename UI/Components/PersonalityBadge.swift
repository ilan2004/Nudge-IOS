import SwiftUI

struct PersonalityBadge: View {
    let personalityType: PersonalityType
    let gender: Gender
    
    private var personalityInfo: (group: String, name: String) {
        switch personalityType.group {
        case .analyst: return ("Analyst", personalityType.displayName)
        case .diplomat: return ("Diplomat", personalityType.displayName)
        case .sentinel: return ("Sentinel", personalityType.displayName)
        case .explorer: return ("Explorer", personalityType.displayName)
        }
    }
    
    private var colors: PersonalityColors {
        PersonalityTheme.colors(for: personalityType, gender: gender)
    }
    
    private var isDarkBackground: Bool {
        // Check if we need light text on dark backgrounds
        [PersonalityType.intj, PersonalityType.entj, PersonalityType.istj, PersonalityType.estj].contains(personalityType)
    }
    
    private var textColor: Color {
        isDarkBackground ? Color.white : Color("GreenText")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Retro console container
            HStack(spacing: 16) {
                // Main MBTI Badge - nav-pill style
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colors.primary)
                        .frame(height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("GreenPrimary"), lineWidth: 2)
                        )
                        .shadow(color: Color("GreenPrimary"), radius: 0, x: 0, y: 4)
                        .shadow(color: Color("GreenPrimary").opacity(0.2), radius: 12, x: 0, y: 8)
                    
                    Text(personalityType.rawValue)
                        .font(.custom("Tanker-Regular", size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .textCase(.uppercase)
                        .kerning(1.2)
                }
                .padding(.horizontal, 20)
                .scaleEffect(1.0)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        // Add subtle tap animation
                    }
                }
                
                // Personality Group badge
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("ComponentSurface"))
                        .frame(height: 32)
                    
                    Text(personalityInfo.group.uppercased())
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("GreenText"))
                        .kerning(1.1)
                }
                .padding(.horizontal, 16)
                
                // Decorative DNA-style elements
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        DNANode(color: colors.primary, delay: Double(index) * 0.3)
                    }
                }
                .opacity(0.7)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("RetroConsoleBG"))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .padding(.top, 24)
    }
}

struct DNANode: View {
    let color: Color
    let delay: Double
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
            .overlay(
                Circle()
                    .stroke(Color("GreenPrimary"), lineWidth: 1)
            )
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .animation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

#Preview {
    VStack(spacing: 30) {
        PersonalityBadge(personalityType: .enfj, gender: .female)
        PersonalityBadge(personalityType: .intj, gender: .male)
        PersonalityBadge(personalityType: .esfp, gender: .neutral)
    }
    .padding()
    .background(Color("Background"))
}
