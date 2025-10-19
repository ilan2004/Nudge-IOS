import SwiftUI

struct ContentView: View {
    @StateObject private var personalityManager = PersonalityManager()
    @StateObject private var focusManager = FocusManager()
    @StateObject private var appSettings = AppSettings()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // App Title
                Text("Nudge")
                    .font(.custom("Tanker-Regular", size: 48))
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                
                // Main Character Card with Focus Ring and Personality Badge
                CharacterCard(title: "Alex", size: 300)
                    .environmentObject(personalityManager)
                    .environmentObject(focusManager)
                
                // Debug Info (can be removed later)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug Info:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Personality: \(personalityManager.personalityType?.rawValue ?? "NONE")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Has Completed Test: \(personalityManager.hasCompletedTest ? "YES" : "NO")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                    Text("Gender: \(personalityManager.gender.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .onAppear {
            setupTestData()
        }
    }
    
    private func setupTestData() {
        // Set ENFJ personality type for testing
        personalityManager.setPersonalityType(.enfj)
        personalityManager.setGender(.male) // You can change to .female to test different images
        personalityManager.markTestCompleted()
        
        print("DEBUG: Set personality to ENFJ")
        print("DEBUG: Personality type: \(personalityManager.personalityType?.rawValue ?? "nil")")
        print("DEBUG: Has completed test: \(personalityManager.hasCompletedTest)")
    }
}

#Preview {
    ContentView()
}
