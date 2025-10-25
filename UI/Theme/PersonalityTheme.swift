import SwiftUI

// MARK: - Personality Types
enum PersonalityType: String, CaseIterable, Codable {
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
enum Gender: String, Codable {
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
        // Core palette from web vars
        let green900 = Color(red: 3/255, green: 89/255, blue: 77/255) // var(--color-green-900)
        let cream = Color(red: 249/255, green: 248/255, blue: 244/255) // var(--color-cream)
        
        // Helper: base (neutral) theme per type from MBTI_Themes.md
        func baseTheme(for type: PersonalityType) -> PersonalityColors {
            switch type {
            case .intj:
                let c = Color(red: 200/255, green: 140/255, blue: 253/255) // purple-400
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: green900, textSecondary: green900.opacity(0.75))
            case .intp:
                let c = Color(red: 174/255, green: 251/255, blue: 255/255) // cyan-200
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: green900, textSecondary: green900.opacity(0.75))
            case .entj:
                let c = Color(red: 255/255, green: 145/255, blue: 36/255) // orange-500
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: cream, textSecondary: cream.opacity(0.85))
            case .entp:
                let c = Color(red: 252/255, green: 86/255, blue: 129/255) // pink-500
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: cream, textSecondary: cream.opacity(0.85))
            case .infj:
                let c = Color(red: 246/255, green: 187/255, blue: 253/255) // lilac-300
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: green900, textSecondary: green900.opacity(0.75))
            case .infp:
                let c = Color(red: 246/255, green: 187/255, blue: 253/255) // lilac-300
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: green900, textSecondary: green900.opacity(0.75))
            case .enfj:
                let c = Color(red: 137/255, green: 169/255, blue: 161/255) // teal-300
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: green900, textSecondary: green900.opacity(0.75))
            case .enfp:
                let c = Color(red: 255/255, green: 255/255, blue: 148/255) // yellow-200
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: green900, textSecondary: green900.opacity(0.75))
            case .istj:
                let c = Color(red: 88/255, green: 154/255, blue: 240/255) // blue-400
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: cream, textSecondary: cream.opacity(0.85))
            case .isfj:
                let c = Color(red: 252/255, green: 205/255, blue: 220/255) // pink-200
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: green900, textSecondary: green900.opacity(0.75))
            case .estj:
                let c = Color(red: 255/255, green: 145/255, blue: 36/255) // orange-500
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: cream, textSecondary: cream.opacity(0.85))
            case .esfj:
                let c = Color(red: 252/255, green: 86/255, blue: 129/255) // pink-500
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: cream, textSecondary: cream.opacity(0.85))
            case .istp:
                let c = Color(red: 137/255, green: 169/255, blue: 161/255) // teal-300
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: green900, textSecondary: green900.opacity(0.75))
            case .isfp:
                let c = Color(red: 246/255, green: 187/255, blue: 253/255) // lilac-300
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: green900, textSecondary: green900.opacity(0.75))
            case .estp:
                let c = Color(red: 255/255, green: 145/255, blue: 36/255) // orange-500
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: cream, textSecondary: cream.opacity(0.85))
            case .esfp:
                let c = Color(red: 255/255, green: 255/255, blue: 148/255) // yellow-200
                return PersonalityColors(primary: c, secondary: c, accent: c, surface: cream, background: c, text: green900, textSecondary: green900.opacity(0.75))
            }
        }
        
        // Gender-aware overrides (background + text) based on group
        func genderOverrides(for group: PersonalityGroup, gender: Gender) -> (bg: Color, text: Color)? {
            switch (group, gender) {
            case (.analyst, .female):
                return (Color(red: 221/255, green: 214/255, blue: 254/255), Color(red: 91/255, green: 33/255, blue: 182/255))
            case (.analyst, .male):
                return (Color(red: 245/255, green: 240/255, blue: 255/255), Color(red: 76/255, green: 29/255, blue: 149/255))
            case (.diplomat, .female):
                return (Color(red: 187/255, green: 247/255, blue: 208/255), Color(red: 154/255, green: 52/255, blue: 18/255))
            case (.diplomat, .male):
                return (Color(red: 240/255, green: 255/255, blue: 245/255), Color(red: 154/255, green: 52/255, blue: 18/255))
            case (.sentinel, .female):
                return (Color(red: 252/255, green: 248/255, blue: 227/255), Color(red: 101/255, green: 67/255, blue: 33/255))
            case (.sentinel, .male):
                return (Color(red: 245/255, green: 245/255, blue: 220/255), Color(red: 45/255, green: 69/255, blue: 28/255))
            case (.explorer, .female):
                return (Color(red: 254/255, green: 240/255, blue: 138/255), Color(red: 161/255, green: 98/255, blue: 7/255))
            case (.explorer, .male):
                return (Color(red: 255/255, green: 248/255, blue: 240/255), Color(red: 153/255, green: 27/255, blue: 27/255))
            default:
                return nil
            }
        }
        
        var theme = baseTheme(for: personalityType)
        if gender != .neutral, let ov = genderOverrides(for: personalityType.group, gender: gender) {
            theme = PersonalityColors(
                primary: theme.primary,
                secondary: theme.secondary,
                accent: theme.accent,
                surface: theme.surface,
                background: ov.bg,
                text: ov.text,
                textSecondary: ov.text.opacity(0.75)
            )
        }
        return theme
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

// MARK: - PersonalityType Extension
extension PersonalityType {
    func colors(for gender: Gender) -> PersonalityColors {
        return PersonalityTheme.colors(for: self, gender: gender)
    }
}
