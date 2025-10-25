import SwiftUI
import UserNotifications

@main
struct NudgeApp: App {
    let persistenceController = PersistenceController.shared
    
    @StateObject private var appSettings = AppSettings()
    @StateObject private var personalityManager = PersonalityManager()
    @StateObject private var focusManager = FocusManager()
    @StateObject private var economyService = EconomyService()
    @StateObject private var restrictionsController = RestrictionsController()
    @StateObject private var roomManager = RoomManager()
    @StateObject private var roomsViewModel = RoomViewModel()
    @StateObject private var friendsManager = FriendsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appSettings)
                .environmentObject(personalityManager)
                .environmentObject(focusManager)
                .environmentObject(economyService)
                .environmentObject(restrictionsController)
                .environmentObject(roomManager)
                .environmentObject(roomsViewModel)
                .environmentObject(friendsManager)
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
        
        Task {
            try? await friendsManager.loadFriends()
            try? await friendsManager.loadFriendRequests()
        }
    }
}
