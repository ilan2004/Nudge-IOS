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
