import SwiftUI
import UserNotifications

@main
struct NudgeApp: App {
    let persistenceController = PersistenceController.shared
    
    @StateObject private var appSettings = AppSettings()
    @StateObject private var personalityManager = PersonalityManager()
    @StateObject private var focusManager = FocusManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView() // FIXED: Using the real ContentView with mint background
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appSettings)
                .environmentObject(personalityManager)
                .environmentObject(focusManager)
                .onAppear {
                    requestNotificationPermissions()
                    loadUserData()
                }
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func loadUserData() {
        personalityManager.loadPersonalityType()
        appSettings.loadSettings()
    }
}
