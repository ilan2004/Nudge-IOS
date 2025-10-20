import SwiftUI

struct ContentView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @EnvironmentObject var focusManager: FocusManager
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Global mint background for all tabs
            Color(red: 130/255, green: 237/255, blue: 166/255).ignoresSafeArea()
            
            TabView {
                // 1) Nudge (Home)
                NudgeHomeView()
                    .foregroundColor(Color.green)
                    .background(Color(red: 130/255, green: 237/255, blue: 166/255).ignoresSafeArea())
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Nudge")
                    }
                
                // 2) Stakes (reuse ContractsView)
                ContractsView()
                    .foregroundColor(Color.green)
                    .background(Color(red: 130/255, green: 237/255, blue: 166/255).ignoresSafeArea())
                    .tabItem {
                        Image(systemName: "handshake.fill")
                        Text("Stakes")
                    }
                
                // 3) My Type
                MyTypeView()
                    .foregroundColor(Color.green)
                    .background(Color(red: 130/255, green: 237/255, blue: 166/255).ignoresSafeArea())
                    .tabItem {
                        Image(systemName: "person.text.rectangle")
                        Text("My Type")
                    }
                
                // 4) Friends / Leaderboard
                LeaderboardView()
                    .foregroundColor(Color.green)
                    .background(Color(red: 130/255, green: 237/255, blue: 166/255).ignoresSafeArea())
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Friends")
                    }
                
                // 5) Profile
                ProfileView()
                    .foregroundColor(Color.green)
                    .background(Color(red: 130/255, green: 237/255, blue: 166/255).ignoresSafeArea())
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
            }
            .background(Color(red: 130/255, green: 237/255, blue: 166/255).ignoresSafeArea())
            
            // Custom tab bar background overlay with retro console surface styling
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 49) // Standard tab bar height
                        .padding(.horizontal, 16)
                        .retroConsoleSurface()
                        .padding(.bottom, 34) // Safe area bottom padding
                    Spacer()
                }
            }
            .allowsHitTesting(false) // Let tab bar touches pass through
            
            // Footer sits above tab bar
            VStack {
                Spacer()
                FooterFocusBarView(viewModel: FooterFocusBarViewModel())
                    .padding(.bottom, 90) // More space above tab bar
            }
        }
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(appSettings.colorScheme)
        .onAppear {
            setupRetroTabBarAppearance()
            print("Tab layout loaded")
            print("Personality type: \(personalityManager.personalityType?.rawValue ?? "nil")")
        }
    }
    
    // MARK: - Tab Bar Styling
    private func setupRetroTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
        // Tab item styling to match retro console surface theme
        let borderColor = UIColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)))
        let normalColor = borderColor.withAlphaComponent(0.6)
        let selectedColor = borderColor
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]
        
        // Apply to all tab bars
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // MARK: - Tabs Content
    struct NudgeHomeView: View {
        @EnvironmentObject var personalityManager: PersonalityManager
        @EnvironmentObject var focusManager: FocusManager
        
        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    CharacterCard(title: "Alex", size: 280)
                    
                    Spacer(minLength: 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.bottom, 180) // Extra padding to avoid footer overlap
            }
        }
    }
    
    struct MyTypeView: View {
        @EnvironmentObject var personalityManager: PersonalityManager
        
        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    if let type = personalityManager.personalityType {
                        PersonalityBadge(personalityType: type, gender: personalityManager.gender)
                            .padding(.top, 12)
                        Text(type.displayName)
                            .font(.title2).bold()
                        Text(type.rawValue)
                            .font(.headline)
                    } else {
                        Text("Take the personality test to see your type")
                            .font(.headline)
                            .padding()
                    }
                    Spacer()
                }
                .padding()
                .padding(.bottom, 180) // Extra padding to avoid footer overlap
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PersonalityManager())
        .environmentObject(FocusManager())
        .environmentObject(AppSettings())
}
