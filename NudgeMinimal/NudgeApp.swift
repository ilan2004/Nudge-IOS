import SwiftUI

@main
struct NudgeApp: App {
    @StateObject private var appSettings = AppSettings()
    @StateObject private var personalityManager = PersonalityManager()
    @StateObject private var focusManager = FocusManager()
    @StateObject private var economyService = EconomyService()
    @StateObject private var restrictionsController = RestrictionsController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .environmentObject(personalityManager)
                .environmentObject(focusManager)
                .environmentObject(economyService)
                .environmentObject(restrictionsController)
        }
    }
}
