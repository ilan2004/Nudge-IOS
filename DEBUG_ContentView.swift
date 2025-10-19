import SwiftUI

// DEBUG VERSION - Simple test to see what's working
struct DEBUG_ContentView: View {
    @StateObject private var personalityManager = PersonalityManager()
    @StateObject private var focusManager = FocusManager()
    @StateObject private var appSettings = AppSettings()
    
    // Exact mint: rgb(130, 237, 166)
    private let exactMint = Color(red: 130/255, green: 237/255, blue: 166/255)
    
    var body: some View {
        ZStack {
            exactMint.ignoresSafeArea()
            
            TabView {
                // 1) Nudge (Home)
                NudgeHomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Nudge")
                    }
                
                // 2) Stakes (reuse ContractsView)
                ContractsView()
                    .tabItem {
                        Image(systemName: "handshake.fill")
                        Text("Stakes")
                    }
                
                // 3) My Type
                MyTypeView()
                    .tabItem {
                        Image(systemName: "person.text.rectangle")
                        Text("My Type")
                    }
                
                // 4) Friends / Leaderboard
                LeaderboardView()
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Friends")
                    }
                
                // 5) Profile
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
            }
            
            // Footer focus bar overlay (debug)
            VStack { Spacer(); FooterFocusBarView(viewModel: FooterFocusBarViewModel()).padding(.horizontal).padding(.bottom, 8) }
            .allowsHitTesting(true)
        }
        .environment(\.dynamicTypeSize, .medium)
        .environmentObject(personalityManager)
        .environmentObject(focusManager)
        .environmentObject(appSettings)
        .onAppear {
            print("DEBUG: Tab layout loaded")
            print("DEBUG: Personality type: \(personalityManager.personalityType?.rawValue ?? "nil")")
        }
    }
    
    // MARK: - Tabs Content (Debug)
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
            }
        }
    }
    
    struct MyTypeView: View {
        @EnvironmentObject var personalityManager: PersonalityManager
        
        var body: some View {
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
        }
    }
}

#Preview {
    DEBUG_ContentView()
}
