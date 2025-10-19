import SwiftUI

// MARK: - Personality Types
enum PersonalityType: String, CaseIterable {
    case intj = "INTJ", intp = "INTP", entj = "ENTJ", entp = "ENTP"
    case infj = "INFJ", infp = "INFP", enfj = "ENFJ", enfp = "ENFP"  
    case istj = "ISTJ", isfj = "ISFJ", estj = "ESTJ", esfj = "ESFJ"
    case istp = "ISTP", isfp = "ISFP", estp = "ESTP", esfp = "ESFP"
    
    var group: PersonalityGroup {
        switch self {
        case .intj, .intp, .entj, .entp: return .analyst
        case .infj, .infp, .enfj, .enfp: return .diplomat
        case .istj, .isfj, .estj, .esfj: return .sentinel
        case .istp, .isfp, .estp, .esfp: return .explorer
        }
    }
    
    var displayName: String {
        switch self {
        case .intj: return "The Architect"
        case .intp: return "The Thinker"
        case .entj: return "The Commander"
        case .entp: return "The Debater"
        case .infj: return "The Advocate"
        case .infp: return "The Mediator"
        case .enfj: return "The Protagonist"
        case .enfp: return "The Campaigner"
        case .istj: return "The Logistician"
        case .isfj: return "The Protector"
        case .estj: return "The Executive"
        case .esfj: return "The Consul"
        case .istp: return "The Virtuoso"
        case .isfp: return "The Adventurer"
        case .estp: return "The Entrepreneur"
        case .esfp: return "The Entertainer"
        }
    }
}

// MARK: - Personality Groups
enum PersonalityGroup: String {
    case analyst = "analyst"
    case diplomat = "diplomat" 
    case sentinel = "sentinel"
    case explorer = "explorer"
}

// MARK: - Gender for personalized theming
enum Gender: String {
    case male = "male"
    case female = "female"
    case neutral = "neutral"
}

// MARK: - Color Scheme
struct PersonalityColors {
    let primary: Color
    let secondary: Color
    let accent: Color
    let surface: Color
    let background: Color
    let text: Color
    let textSecondary: Color
}

// MARK: - Personality Theme Manager
struct PersonalityTheme {
    
    // Default colors matching your web app
    static let defaultColors = PersonalityColors(
        primary: Color("MintPrimary", bundle: nil),
        secondary: Color("GreenSecondary", bundle: nil),
        accent: Color("PinkAccent", bundle: nil),
        surface: Color("CreamSurface", bundle: nil),
        background: Color("BackgroundDefault", bundle: nil),
        text: Color("GreenText", bundle: nil),
        textSecondary: Color("GrayText", bundle: nil)
    )
    
    static func colors(for personalityType: PersonalityType, gender: Gender = .neutral) -> PersonalityColors {
        
        // Base MBTI colors from your web app
        let mbtiColors: [PersonalityType: PersonalityColors] = [
            .intj: PersonalityColors(
                primary: Color("PurplePrimary", bundle: nil),
                secondary: Color("PurpleSecondary", bundle: nil),
                accent: Color("PurpleAccent", bundle: nil),
                surface: Color("CreamSurface", bundle: nil),
                background: Color("BackgroundDefault", bundle: nil),
                text: Color("GreenText", bundle: nil),
                textSecondary: Color("GrayText", bundle: nil)
            ),
            .intp: PersonalityColors(
                primary: Color("CyanPrimary", bundle: nil),
                secondary: Color("CyanSecondary", bundle: nil),
                accent: Color("CyanAccent", bundle: nil),
                surface: Color("CreamSurface", bundle: nil),
                background: Color("BackgroundDefault", bundle: nil),
                text: Color("GreenText", bundle: nil),
                textSecondary: Color("GrayText", bundle: nil)
            ),
            .entj: PersonalityColors(
                primary: Color("OrangePrimary", bundle: nil),
                secondary: Color("OrangeSecondary", bundle: nil),
                accent: Color("OrangeAccent", bundle: nil),
                surface: Color("CreamSurface", bundle: nil),
                background: Color("BackgroundDefault", bundle: nil),
                text: Color("CreamText", bundle: nil),
                textSecondary: Color("LightGrayText", bundle: nil)
            ),
            .entp: PersonalityColors(
                primary: Color("PinkPrimary", bundle: nil),
                secondary: Color("PinkSecondary", bundle: nil),
                accent: Color("PinkAccent", bundle: nil),
                surface: Color("CreamSurface", bundle: nil),
                background: Color("BackgroundDefault", bundle: nil),
                text: Color("CreamText", bundle: nil),
                textSecondary: Color("LightGrayText", bundle: nil)
            ),
            .infj: PersonalityColors(
                primary: Color("PurplePrimary", bundle: nil),
                secondary: Color("PurpleSecondary", bundle: nil),
                accent: Color("PurpleAccent", bundle: nil),
                surface: Color("CreamSurface", bundle: nil),
                background: Color("BackgroundDefault", bundle: nil),
                text: Color("GreenText", bundle: nil),
                textSecondary: Color("GrayText", bundle: nil)
            ),
            .infp: PersonalityColors(
                primary: Color("LilacPrimary", bundle: nil),
                secondary: Color("LilacSecondary", bundle: nil),
                accent: Color("LilacAccent", bundle: nil),
                surface: Color("CreamSurface", bundle: nil),
                background: Color("BackgroundDefault", bundle: nil),
                text: Color("GreenText", bundle: nil),
                textSecondary: Color("GrayText", bundle: nil)
            ),
            .enfj: PersonalityColors(
                primary: Color("TealPrimary", bundle: nil),
                secondary: Color("TealSecondary", bundle: nil),
                accent: Color("TealAccent", bundle: nil),
                surface: Color("CreamSurface", bundle: nil),
                background: Color("BackgroundDefault", bundle: nil),
                text: Color("GreenText", bundle: nil),
                textSecondary: Color("GrayText", bundle: nil)
            ),
            .enfp: PersonalityColors(
                primary: Color("YellowPrimary", bundle: nil),
                secondary: Color("YellowSecondary", bundle: nil),
                accent: Color("YellowAccent", bundle: nil),
                surface: Color("CreamSurface", bundle: nil),
                background: Color("BackgroundDefault", bundle: nil),
                text: Color("GreenText", bundle: nil),
                textSecondary: Color("GrayText", bundle: nil)
            ),
            // Continue for other personality types...
        ]
        
        return mbtiColors[personalityType] ?? defaultColors
    }
    
    // Current personality theme (global access)
    static var currentPrimaryColor: Color {
        // This will be updated when personality is set
        return defaultColors.primary
    }
    
    // Helper for getting image and video names
    static func mediaName(for personalityType: PersonalityType, gender: Gender = .neutral, isVideo: Bool = false) -> String {
        let genderSuffix: String
        switch gender {
        case .male: return personalityType.rawValue + "M"
        case .female: return personalityType.rawValue + "W"  
        case .neutral: return personalityType.rawValue + "M" // Default to male version
        }
    }
}
