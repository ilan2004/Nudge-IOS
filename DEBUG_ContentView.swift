import SwiftUI

// DEBUG VERSION - Simple test to see what's working
struct DEBUG_ContentView: View {
    @StateObject private var personalityManager = PersonalityManager()
    @StateObject private var focusManager = FocusManager()
    @StateObject private var appSettings = AppSettings()
    
    var body: some View {
        VStack(spacing: 20) {
            
            
            
            // Test 3: Simple CharacterCard
            CharacterCard(title: "Debug User", size: 200)
                .environmentObject(personalityManager)
                .environmentObject(focusManager)
            
            Spacer()
        }
        .padding()
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
