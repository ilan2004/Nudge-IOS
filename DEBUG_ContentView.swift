import SwiftUI

// DEBUG VERSION - Simple test to see what's working
struct DEBUG_ContentView: View {
    @StateObject private var personalityManager = PersonalityManager()
    @StateObject private var focusManager = FocusManager()
    @StateObject private var appSettings = AppSettings()
    
    // Exact mint: rgb(130, 237, 166)
    private let exactMint = Color(red: 130/255, green: 237/255, blue: 166/255)
    
    var body: some View {
        VStack(spacing: 20) {
            // Main dashboard debug layout you preferred
            CharacterCard(title: "Alex", size: 280)
                .environmentObject(personalityManager)
                .environmentObject(focusManager)
            
            FocusStatsCard()
                .environmentObject(personalityManager)
            
            QuickActionsCard()
                .environmentObject(personalityManager)
            
            RecentActivityCard()
                .environmentObject(personalityManager)
            
            Spacer(minLength: 24)
        }
        .padding(.horizontal, 16)
        .background(exactMint.ignoresSafeArea())
        .environment(\.dynamicTypeSize, .medium)
        .onAppear {
            print("DEBUG: ContentView appeared")
            print("DEBUG: Personality type: \(personalityManager.personalityType?.rawValue ?? "nil")")
            print("DEBUG: Has completed test: \(personalityManager.hasCompletedTest)")
        }
    }
}

#Preview {
    DEBUG_ContentView()
}
