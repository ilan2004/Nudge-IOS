import SwiftUI

// MARK: - Personality Test View
struct PersonalityTestView: View {
    let username: String
    let gender: Gender
    @EnvironmentObject var personalityManager: PersonalityManager
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestion = 0
    @State private var answers: [TestAnswer] = []
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Personality Assessment")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Question \(currentQuestion + 1) of 10")
                .foregroundColor(.secondary)
            
            // Progress bar
            ProgressView(value: Double(currentQuestion), total: 10)
                .padding(.horizontal)
            
            Spacer()
            
            Text("This is a placeholder for the personality test.")
                .multilineTextAlignment(.center)
                .padding()
            
            Text("Username: \(username)")
            Text("Gender: \(gender.rawValue)")
            
            Spacer()
            
            Button("Complete Test (Demo)") {
                // Demo: Assign random personality type
                let demoType: PersonalityType = .infp
                personalityManager.savePersonalityResult(type: demoType, gender: gender, scores: [:])
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(PersonalityTheme.defaultColors.primary)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Focus View
struct FocusView: View {
    @EnvironmentObject var focusManager: FocusManager
    @EnvironmentObject var personalityManager: PersonalityManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Text("Focus Timer")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(personalityManager.currentTheme.text)
                
                // Timer Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: focusManager.progress)
                        .stroke(PersonalityTheme.defaultColors.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 8) {
                        Text(timeString(from: focusManager.remainingTime))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(personalityManager.currentTheme.text)
                        
                        Text(focusManager.currentSessionType)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Control Buttons
                HStack(spacing: 20) {
                    if focusManager.currentState == .idle {
                        Button("Start Focus") {
                            focusManager.startFocusSession()
                        }
                        .buttonStyle(.borderedProminent)
                    } else if focusManager.currentState == .paused {
                        Button("Resume") {
                            focusManager.resumeSession()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Pause") {
                            focusManager.pauseSession()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if focusManager.currentState != .idle {
                        Button("End") {
                            focusManager.endSession()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
                
                // Stats
                VStack(spacing: 12) {
                    HStack {
                        Text("Sessions Today: \(focusManager.sessionsCompleted)")
                        Spacer()
                        Text("Streak: \(focusManager.currentStreak) days")
                    }
                    .font(.headline)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Focus")
            .background(Color.clear)
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Leaderboard")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(personalityManager.currentTheme.text)
                
                Text("Social features coming soon!")
                    .foregroundColor(.secondary)
                
                // Mock leaderboard
                VStack(spacing: 16) {
                    LeaderboardRow(rank: 1, name: "You", score: 1250, isCurrentUser: true)
                    LeaderboardRow(rank: 2, name: "Alex", score: 1180, isCurrentUser: false)
                    LeaderboardRow(rank: 3, name: "Sarah", score: 1050, isCurrentUser: false)
                    LeaderboardRow(rank: 4, name: "Mike", score: 950, isCurrentUser: false)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Leaderboard")
            .background(Color.clear)
        }
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let name: String
    let score: Int
    let isCurrentUser: Bool
    @EnvironmentObject var personalityManager: PersonalityManager
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(.headline)
                .foregroundColor(isCurrentUser ? PersonalityTheme.defaultColors.primary : personalityManager.currentTheme.textSecondary)
                .frame(width: 30)
            
            Text(name)
                .font(.body)
                .fontWeight(isCurrentUser ? .semibold : .regular)
                .foregroundColor(personalityManager.currentTheme.text)
            
            Spacer()
            
            Text("\(score) pts")
                .font(.body)
                .foregroundColor(personalityManager.currentTheme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Contracts View
struct ContractsView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Contracts")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(personalityManager.currentTheme.text)
                
                Text("Accountability system coming soon!")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Contracts")
            .background(Color.clear)
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Header
                if let personalityType = personalityManager.personalityType {
                    VStack(spacing: 16) {
                        // Personality Image
                        if let imageName = personalityManager.getPersonalityImageName() {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        }
                        
                        Text(personalityType.displayName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(personalityType.rawValue)
                            .font(.custom("Tanker-Regular", size: 20))
                            .foregroundColor(personalityManager.currentTheme.primary)
                    }
                }
                
                // Settings Options
                VStack(spacing: 16) {
                    SettingsRow(title: "Retake Personality Test", icon: "person.fill") {
                        personalityManager.resetPersonalityData()
                    }
                    
                    SettingsRow(title: "Notifications", icon: "bell.fill") {
                        // TODO: Navigate to notification settings
                    }
                    
                    SettingsRow(title: "About", icon: "info.circle.fill") {
                        // TODO: Navigate to about page
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .background(Color.clear)
        }
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.primary)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
    }
}

// Import required for NSPersistentContainer
import CoreData

// MARK: - Personality Questions (Placeholder)
struct PersonalityQuestions {
    static func getQuestion(id: String) -> PersonalityQuestion? {
        // Placeholder implementation
        return PersonalityQuestion(id: id, text: "Sample question", scoring: ["E": 1])
    }
}

struct PersonalityQuestion {
    let id: String
    let text: String
    let scoring: [String: Int] // Dimension weights
}
