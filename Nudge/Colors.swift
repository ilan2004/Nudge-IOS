import SwiftUI

// MARK: - Color Extension for Named Colors
extension Color {
    // Base Theme Colors (matching CSS variables)
    static let surface = Color("Surface")
    static let background = Color("Background") 
    static let componentSurface = Color("ComponentSurface")
    static let retroConsoleBG = Color("RetroConsoleBG")
    
    // Primary Colors
    static let greenPrimary = Color("GreenPrimary") // var(--color-green-900)
    static let mintPrimary = Color("MintPrimary") // var(--color-mint-500)
    
    // Text Colors
    static let greenText = Color("GreenText") // var(--color-green-900)
    static let creamText = Color("CreamText") // var(--color-cream)
    static let grayText = Color("GrayText")
    static let lightGrayText = Color("LightGrayText")
    
    // Accent Colors for Personality Types
    static let purplePrimary = Color("PurplePrimary") // var(--color-purple-400)
    static let cyanPrimary = Color("CyanPrimary") // var(--color-cyan-200)
    static let orangePrimary = Color("OrangePrimary") // var(--color-orange-500)
    static let pinkPrimary = Color("PinkPrimary") // var(--color-pink-500)
    static let bluePrimary = Color("BluePrimary") // var(--color-blue-400)
    static let tealPrimary = Color("TealPrimary") // var(--color-teal-300)
    static let amberPrimary = Color("AmberPrimary") // var(--color-amber-400)
    static let lilacPrimary = Color("LilacPrimary") // var(--color-lilac-300)
    static let yellowPrimary = Color("YellowPrimary") // var(--color-yellow-200)
    
    // Accent variants
    static let blueAccent = Color("BlueAccent")
    static let tealAccent = Color("TealAccent")
    static let pinkAccent = Color("PinkAccent")
}

// MARK: - Static Color Definitions
// For use when Asset Catalog colors are not available
extension Color {
    static func personalityColor(for type: PersonalityType) -> Color {
        switch type {
        case .intj: return Color(red: 0.627, green: 0.322, blue: 0.714) // Purple
        case .intp: return Color(red: 0.678, green: 0.847, blue: 0.902) // Cyan
        case .entj: return Color(red: 1.0, green: 0.596, blue: 0.0) // Orange
        case .entp: return Color(red: 1.0, green: 0.411, blue: 0.706) // Pink
        case .infj: return Color(red: 0.392, green: 0.584, blue: 0.929) // Blue
        case .infp: return Color(red: 0.918, green: 0.667, blue: 0.851) // Pink Light
        case .enfj: return Color(red: 0.439, green: 0.859, blue: 0.804) // Teal
        case .enfp: return Color(red: 1.0, green: 0.757, blue: 0.027) // Amber
        case .istj: return Color(red: 0.392, green: 0.584, blue: 0.929) // Blue
        case .isfj: return Color(red: 0.918, green: 0.667, blue: 0.851) // Pink Light
        case .estj: return Color(red: 1.0, green: 0.596, blue: 0.0) // Orange
        case .esfj: return Color(red: 1.0, green: 0.411, blue: 0.706) // Pink
        case .istp: return Color(red: 0.439, green: 0.859, blue: 0.804) // Teal
        case .isfp: return Color(red: 0.878, green: 0.804, blue: 0.937) // Lilac
        case .estp: return Color(red: 1.0, green: 0.757, blue: 0.027) // Amber
        case .esfp: return Color(red: 1.0, green: 0.898, blue: 0.616) // Yellow
        }
    }
    
    // Base theme colors as static values
    static let defaultGreen = Color(red: 0.055, green: 0.259, blue: 0.184) // #0E4238
    static let defaultMint = Color(red: 0.063, green: 0.737, blue: 0.502) // #10BC80
    static let defaultCream = Color(red: 0.988, green: 0.973, blue: 0.949) // #FCF8F2
    static let defaultSurface = Color(red: 0.988, green: 0.973, blue: 0.949) // Same as cream
}
