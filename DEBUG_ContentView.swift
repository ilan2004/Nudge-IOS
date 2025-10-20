import SwiftUI

// DEBUG VERSION - Simple test to see what's working
struct DEBUG_ContentView: View {
    @StateObject private var personalityManager = PersonalityManager()
    @StateObject private var focusManager = FocusManager()
    @StateObject private var appSettings = AppSettings()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Global mint background for all tabs - hardcoded RGB
            Color(red: 0.063, green: 0.737, blue: 0.502).ignoresSafeArea()
            
            TabView {
                // 1) Nudge (Home)
                NudgeHomeView()
                    .foregroundColor(Color.greenPrimary)
                    .background(Color(red: 0.063, green: 0.737, blue: 0.502).ignoresSafeArea())
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Nudge")
                    }
                
                // 2) Stakes (reuse ContractsView)
                ContractsView()
                    .foregroundColor(Color.greenPrimary)
                    .background(Color(red: 0.063, green: 0.737, blue: 0.502).ignoresSafeArea())
                    .tabItem {
                        Image(systemName: "handshake.fill")
                        Text("Stakes")
                    }
                
                // 3) My Type
                MyTypeView()
                    .foregroundColor(Color.greenPrimary)
                    .background(Color(red: 0.063, green: 0.737, blue: 0.502).ignoresSafeArea())
                    .tabItem {
                        Image(systemName: "person.text.rectangle")
                        Text("My Type")
                    }
                
                // 4) Friends / Leaderboard
                LeaderboardView()
                    .foregroundColor(Color.greenPrimary)
                    .background(Color(red: 0.063, green: 0.737, blue: 0.502).ignoresSafeArea())
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Friends")
                    }
                
                // 5) Profile
                ProfileView()
                    .foregroundColor(Color.greenPrimary)
                    .background(Color(red: 0.063, green: 0.737, blue: 0.502).ignoresSafeArea())
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
            }
            .background(Color(red: 0.063, green: 0.737, blue: 0.502).ignoresSafeArea())
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
                VStack(spacing: 12) {
                    CharacterCard(title: "Alex", size: 280)
                    
                    // Footer focus bar positioned directly under the character card (debug)
                    FooterFocusBarView(viewModel: FooterFocusBarViewModel())
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
    }
    
    struct MyTypeView: View {
        @EnvironmentObject var personalityManager: PersonalityManager
        
        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    if let type = personalityManager.personalityType {
                        // PersonalityBadge temporarily removed in debug main view
                        Text(type.displayName)
                            .font(.title2).bold()
                            .padding(.top, 12)
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
    DEBUG_ContentView()
}
