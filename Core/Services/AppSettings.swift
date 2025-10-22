import SwiftUI
import Combine

class AppSettings: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil
    @Published var notificationsEnabled: Bool = true
    @Published var soundEnabled: Bool = true
    @Published var hapticFeedbackEnabled: Bool = true
    @Published var defaultFocusTime: Int = 25 // minutes
    @Published var defaultBreakTime: Int = 5 // minutes
    @Published var undergroundMode: Bool = false { // Privacy/stealth layer
        didSet { saveSettings() }
    }
    
    private let userDefaults = UserDefaults.standard
    
    // UserDefaults keys
    private let colorSchemeKey = "nudge_color_scheme"
    private let notificationsEnabledKey = "nudge_notifications_enabled"
    private let soundEnabledKey = "nudge_sound_enabled"
    private let hapticFeedbackEnabledKey = "nudge_haptic_feedback_enabled"
    private let defaultFocusTimeKey = "nudge_default_focus_time"
    private let defaultBreakTimeKey = "nudge_default_break_time"
    private let undergroundModeKey = "nudge_underground_mode"
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        // Load color scheme
        if let schemeString = userDefaults.string(forKey: colorSchemeKey) {
            switch schemeString {
            case "light": colorScheme = .light
            case "dark": colorScheme = .dark
            default: colorScheme = nil // System default
            }
        }
        
        // Load other settings
        notificationsEnabled = userDefaults.object(forKey: notificationsEnabledKey) as? Bool ?? true
        soundEnabled = userDefaults.object(forKey: soundEnabledKey) as? Bool ?? true
        hapticFeedbackEnabled = userDefaults.object(forKey: hapticFeedbackEnabledKey) as? Bool ?? true
        defaultFocusTime = userDefaults.object(forKey: defaultFocusTimeKey) as? Int ?? 25
        defaultBreakTime = userDefaults.object(forKey: defaultBreakTimeKey) as? Int ?? 5
        undergroundMode = userDefaults.object(forKey: undergroundModeKey) as? Bool ?? false
    }
    
    func saveSettings() {
        // Save color scheme
        let schemeString: String?
        switch colorScheme {
        case .light: schemeString = "light"
        case .dark: schemeString = "dark"
        default: schemeString = nil
        }
        
        if let schemeString = schemeString {
            userDefaults.set(schemeString, forKey: colorSchemeKey)
        } else {
            userDefaults.removeObject(forKey: colorSchemeKey)
        }
        
        // Save other settings
        userDefaults.set(notificationsEnabled, forKey: notificationsEnabledKey)
        userDefaults.set(soundEnabled, forKey: soundEnabledKey)
        userDefaults.set(hapticFeedbackEnabled, forKey: hapticFeedbackEnabledKey)
        userDefaults.set(defaultFocusTime, forKey: defaultFocusTimeKey)
        userDefaults.set(defaultBreakTime, forKey: defaultBreakTimeKey)
        userDefaults.set(undergroundMode, forKey: undergroundModeKey)
    }
}
