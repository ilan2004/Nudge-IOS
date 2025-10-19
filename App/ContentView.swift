import SwiftUI

struct ContentView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @EnvironmentObject var appSettings: AppSettings
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            // FOR TESTING: Always show main app (personality manager loads ENFJ by default)
            MainTabView(selectedTab: $selectedTab)
        }
        .background(Color(red: 0.063, green: 0.737, blue: 0.502).ignoresSafeArea()) // HARDCODED mint background
        .preferredColorScheme(appSettings.colorScheme)
        .onAppear {
            setupAppAppearance()
        }
    }
    
    private func setupAppAppearance() {
        // Configure tab bar appearance with mint background
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        
        // Force mint background for tab bar
        let mintColor = UIColor(Color(red: 0.063, green: 0.737, blue: 0.502))
        tabBarAppearance.backgroundColor = mintColor
        
        if let personalityType = personalityManager.personalityType {
            let colors = PersonalityTheme.colors(for: personalityType)
            tabBarAppearance.selectionIndicatorTintColor = UIColor(colors.primary)
        }
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Also set global window background to mint
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.backgroundColor = mintColor
            }
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var focusManager: FocusManager
    @EnvironmentObject var personalityManager: PersonalityManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            FocusView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Focus")
                }
                .tag(1)
                .badge(focusManager.isActive ? "●" : "")
            
            LeaderboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Leaderboard")
                }
                .tag(2)
            
            ContractsView()
                .tabItem {
                    Image(systemName: "handshake.fill")
                    Text("Contracts")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .background(Color(red: 0.063, green: 0.737, blue: 0.502).ignoresSafeArea()) // HARDCODED mint background
        .accentColor(PersonalityTheme.currentPrimaryColor)
    }
}

#Preview {
    ContentView()
        .environmentObject(PersonalityManager())
        .environmentObject(AppSettings())
        .environmentObject(FocusManager())
}
