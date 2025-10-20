import SwiftUI

// DEBUG VERSION - Simple test to see what's working
struct DEBUG_ContentView: View {
    @StateObject private var personalityManager = PersonalityManager()
    @StateObject private var focusManager = FocusManager()
    @StateObject private var appSettings = AppSettings()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Global mint background for all tabs
            Color.mintPrimary.ignoresSafeArea()
            
            TabView {
                // 1) Nudge (Home)
                NudgeHomeView()
                    .foregroundColor(.greenPrimary)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Nudge")
                    }
                
                // 2) Stakes (reuse ContractsView)
                ContractsView()
                    .foregroundColor(.greenPrimary)
                    .tabItem {
                        Image(systemName: "handshake.fill")
                        Text("Stakes")
                    }
                
                // 3) My Type
                MyTypeView()
                    .foregroundColor(.greenPrimary)
                    .tabItem {
                        Image(systemName: "person.text.rectangle")
                        Text("My Type")
                    }
                
                // 4) Friends / Leaderboard
                LeaderboardView()
                    .foregroundColor(.greenPrimary)
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Friends")
                    }
                
                // 5) Profile
                ProfileView()
                    .foregroundColor(.greenPrimary)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
            }
            
            // Footer sits above tab bar
            VStack {
                Spacer()
                FooterFocusBarView(viewModel: FooterFocusBarViewModel())
                    .background(Color(red: 0.96, green: 0.96, blue: 0.94))
                    .padding(.bottom, 90) // More space above tab bar
            }
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
    DEBUG_ContentView()
}
