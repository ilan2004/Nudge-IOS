import SwiftUI

// DEBUG VERSION - Simple test to see what's working
struct DEBUG_ContentView: View {
    @StateObject private var personalityManager = PersonalityManager()
    @StateObject private var focusManager = FocusManager()
    @StateObject private var appSettings = AppSettings()
    
    // Exact mint: rgb(130, 237, 166)
    private let exactMint = Color(red: 130/255, green: 237/255, blue: 166/255)
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Character only
                CharacterCard(title: "Alex", size: 280)
                    .environmentObject(personalityManager)
                    .environmentObject(focusManager)
                
                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
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
