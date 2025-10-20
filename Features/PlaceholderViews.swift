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
                    .foregroundColor(.gray)
            
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
            .background(Color(red: 0.063, green: 0.737, blue: 0.502))
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
                    .foregroundColor(.white)
                
                // Timer Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: focusManager.progress)
                        .stroke(Color(red: 0.063, green: 0.737, blue: 0.502), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 8) {
                        Text(timeString(from: focusManager.remainingTime))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(focusManager.currentSessionType)
                            .font(.headline)
                            .foregroundColor(.gray)
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
                .background(Color.clear)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Focus")
            .background(Color.clear)
            .scrollContentBackground(.hidden)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
