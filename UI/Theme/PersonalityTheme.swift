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
        primary: Color(red: 0.063, green: 0.737, blue: 0.502), // #10BC80 - mint
        secondary: Color(red: 0.055, green: 0.259, blue: 0.184), // #0E4238 - green
        accent: Color(red: 1.0, green: 0.411, blue: 0.706), // #FF69B4 - pink
        surface: Color(red: 0.988, green: 0.973, blue: 0.949), // #FCF8F2 - cream
        background: Color(red: 0.063, green: 0.737, blue: 0.502), // #10BC80 - mint (CHANGED)
        text: Color.white, // Changed to white for better contrast on mint background
        textSecondary: Color(red: 0.9, green: 0.9, blue: 0.9) // Light gray for secondary text
    )
    
    static func colors(for personalityType: PersonalityType, gender: Gender = .neutral) -> PersonalityColors {
        
        // Base MBTI colors from your web app - using static colors for immediate testing
        let mbtiColors: [PersonalityType: PersonalityColors] = [
            .intj: PersonalityColors(
                primary: Color(red: 0.627, green: 0.322, blue: 0.714), // purple
                secondary: Color(red: 0.627, green: 0.322, blue: 0.714),
                accent: Color(red: 0.627, green: 0.322, blue: 0.714),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white, // white text on mint background
                textSecondary: Color(red: 0.6, green: 0.6, blue: 0.6)
            ),
            .intp: PersonalityColors(
                primary: Color(red: 0.678, green: 0.847, blue: 0.902), // cyan
                secondary: Color(red: 0.678, green: 0.847, blue: 0.902),
                accent: Color(red: 0.678, green: 0.847, blue: 0.902),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white, // white text on mint background
                textSecondary: Color(red: 0.9, green: 0.9, blue: 0.9)
            ),
            .entj: PersonalityColors(
                primary: Color(red: 1.0, green: 0.596, blue: 0.0), // orange
                secondary: Color(red: 1.0, green: 0.596, blue: 0.0),
                accent: Color(red: 1.0, green: 0.596, blue: 0.0),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.988, green: 0.973, blue: 0.949),
                text: Color.white,
                textSecondary: Color(red: 0.8, green: 0.8, blue: 0.8)
            ),
            .entp: PersonalityColors(
                primary: Color(red: 1.0, green: 0.411, blue: 0.706), // pink
                secondary: Color(red: 1.0, green: 0.411, blue: 0.706),
                accent: Color(red: 1.0, green: 0.411, blue: 0.706),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.988, green: 0.973, blue: 0.949),
                text: Color.white,
                textSecondary: Color(red: 0.8, green: 0.8, blue: 0.8)
            ),
            .infj: PersonalityColors(
                primary: Color(red: 0.392, green: 0.584, blue: 0.929), // blue
                secondary: Color(red: 0.392, green: 0.584, blue: 0.929),
                accent: Color(red: 0.392, green: 0.584, blue: 0.929),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white, // white text on mint background
                textSecondary: Color(red: 0.9, green: 0.9, blue: 0.9)
            ),
            .infp: PersonalityColors(
                primary: Color(red: 0.878, green: 0.804, blue: 0.937), // lilac
                secondary: Color(red: 0.878, green: 0.804, blue: 0.937),
                accent: Color(red: 0.878, green: 0.804, blue: 0.937),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white, // white text on mint background
                textSecondary: Color(red: 0.9, green: 0.9, blue: 0.9)
            ),
            .enfj: PersonalityColors(
                primary: Color(red: 0.439, green: 0.859, blue: 0.804), // teal - ENFJ!
                secondary: Color(red: 0.439, green: 0.859, blue: 0.804),
                accent: Color(red: 0.439, green: 0.859, blue: 0.804),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white, // white text on mint background
                textSecondary: Color(red: 0.9, green: 0.9, blue: 0.9)
            ),
            .enfp: PersonalityColors(
                primary: Color(red: 1.0, green: 0.898, blue: 0.616), // yellow
                secondary: Color(red: 1.0, green: 0.898, blue: 0.616),
                accent: Color(red: 1.0, green: 0.898, blue: 0.616),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white, // white text on mint background
                textSecondary: Color(red: 0.9, green: 0.9, blue: 0.9)
            ),
            .istj: PersonalityColors(
                primary: Color(red: 0.392, green: 0.584, blue: 0.929), // blue
                secondary: Color(red: 0.392, green: 0.584, blue: 0.929),
                accent: Color(red: 0.392, green: 0.584, blue: 0.929),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white, // white text on mint background
                textSecondary: Color(red: 0.9, green: 0.9, blue: 0.9)
            ),
            .isfj: PersonalityColors(
                primary: Color(red: 0.918, green: 0.667, blue: 0.851), // pink light
                secondary: Color(red: 0.918, green: 0.667, blue: 0.851),
                accent: Color(red: 0.918, green: 0.667, blue: 0.851),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white, // white text on mint background
                textSecondary: Color(red: 0.9, green: 0.9, blue: 0.9)
            ),
            .estj: PersonalityColors(
                primary: Color(red: 1.0, green: 0.596, blue: 0.0), // orange
                secondary: Color(red: 1.0, green: 0.596, blue: 0.0),
                accent: Color(red: 1.0, green: 0.596, blue: 0.0),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white,
                textSecondary: Color(red: 0.8, green: 0.8, blue: 0.8)
            ),
            .esfj: PersonalityColors(
                primary: Color(red: 1.0, green: 0.411, blue: 0.706), // pink
                secondary: Color(red: 1.0, green: 0.411, blue: 0.706),
                accent: Color(red: 1.0, green: 0.411, blue: 0.706),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white,
                textSecondary: Color(red: 0.8, green: 0.8, blue: 0.8)
            ),
            .istp: PersonalityColors(
                primary: Color(red: 0.439, green: 0.859, blue: 0.804), // teal
                secondary: Color(red: 0.439, green: 0.859, blue: 0.804),
                accent: Color(red: 0.439, green: 0.859, blue: 0.804),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white, // white text on mint background
                textSecondary: Color(red: 0.9, green: 0.9, blue: 0.9)
            ),
            .isfp: PersonalityColors(
                primary: Color(red: 0.878, green: 0.804, blue: 0.937), // lilac
                secondary: Color(red: 0.878, green: 0.804, blue: 0.937),
                accent: Color(red: 0.878, green: 0.804, blue: 0.937),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white, // white text on mint background
                textSecondary: Color(red: 0.9, green: 0.9, blue: 0.9)
            ),
            .estp: PersonalityColors(
                primary: Color(red: 1.0, green: 0.757, blue: 0.027), // amber
                secondary: Color(red: 1.0, green: 0.757, blue: 0.027),
                accent: Color(red: 1.0, green: 0.757, blue: 0.027),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white,
                textSecondary: Color(red: 0.8, green: 0.8, blue: 0.8)
            ),
            .esfp: PersonalityColors(
                primary: Color(red: 1.0, green: 0.898, blue: 0.616), // yellow
                secondary: Color(red: 1.0, green: 0.898, blue: 0.616),
                accent: Color(red: 1.0, green: 0.898, blue: 0.616),
                surface: Color(red: 0.988, green: 0.973, blue: 0.949),
                background: Color(red: 0.063, green: 0.737, blue: 0.502), // mint background
                text: Color.white, // white text on mint background
                textSecondary: Color(red: 0.9, green: 0.9, blue: 0.9)
            )
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
        case .male: 
            genderSuffix = "M"
        case .female: 
            genderSuffix = "W"
        case .neutral: 
            genderSuffix = "M" // Default to male version
        }
        return personalityType.rawValue + genderSuffix
    }
}
