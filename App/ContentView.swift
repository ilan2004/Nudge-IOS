import SwiftUI

struct ContentView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @EnvironmentObject var focusManager: FocusManager
    @EnvironmentObject var appSettings: AppSettings
    
    @State private var selectedTab = 0
    
    private var tabs: [TabItem] {
        [
            TabItem(icon: "house.fill", title: "Nudge") { NudgeHomeView() },
            TabItem(icon: "handshake.fill", title: "Stakes") { ContractsView() },
            TabItem(icon: "person.text.rectangle", title: "My Type") { MyTypeView() },
            TabItem(icon: "person.3.fill", title: "Friends") { LeaderboardView() },
            TabItem(icon: "person.fill", title: "Profile") { ProfileView() }
        ]
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Global mint background for all tabs
            Color(red: 130/255, green: 237/255, blue: 166/255).ignoresSafeArea()
            
            // Main content area
            VStack(spacing: 0) {
                // Current tab content
                if selectedTab < tabs.count {
                    tabs[selectedTab].view
                        .foregroundColor(Color.green)
                        .background(Color(red: 130/255, green: 237/255, blue: 166/255).ignoresSafeArea())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Color.clear
                }
            }
            
            // Footer sits above custom tab bar
            VStack {
                Spacer()
                FooterFocusBarView(viewModel: FooterFocusBarViewModel())
                    .padding(.bottom, 120) // More space above custom tab bar
            }
            
            // Custom retro tab bar at bottom
            VStack {
                Spacer()
                RetroTabBar(selectedTab: $selectedTab, tabs: tabs)
                    .padding(.bottom, 34) // Safe area padding
            }
        }
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(appSettings.colorScheme)
        .onAppear {
            print("Tab layout loaded")
            print("Personality type: \(personalityManager.personalityType?.rawValue ?? "nil")")
        }
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
