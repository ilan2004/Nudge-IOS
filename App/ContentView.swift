import SwiftUI

struct ContentView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @EnvironmentObject var appSettings: AppSettings
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if !personalityManager.hasCompletedTest {
                OnboardingView()
            } else {
                MainTabView(selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(appSettings.colorScheme)
        .onAppear {
            setupAppAppearance()
        }
    }
    
    private func setupAppAppearance() {
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        if let personalityType = personalityManager.personalityType {
            let colors = PersonalityTheme.colors(for: personalityType)
            tabBarAppearance.backgroundColor = UIColor(colors.surface)
            tabBarAppearance.selectionIndicatorTintColor = UIColor(colors.primary)
        }
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var focusManager: FocusManager
    
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
        .accentColor(PersonalityTheme.currentPrimaryColor)
    }
}

#Preview {
    ContentView()
        .environmentObject(PersonalityManager())
        .environmentObject(AppSettings())
        .environmentObject(FocusManager())
}
