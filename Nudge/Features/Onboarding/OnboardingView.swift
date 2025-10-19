import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @State private var currentStep = 0
    @State private var username = ""
    @State private var selectedGender: Gender = .neutral
    @State private var showingTest = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                // App Logo
                Image("nudge2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Welcome Content
                VStack(spacing: 16) {
                    Text("Welcome to Nudge")
                        .font(.custom("Tanker-Regular", size: 32))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Your personality-driven focus companion")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Setup Form
                VStack(spacing: 20) {
                    // Username Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What should we call you?")
                            .font(.headline)
                        
                        TextField("Enter your name", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    
                    // Gender Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gender (for personalized theming)")
                            .font(.headline)
                        
                        Picker("Gender", selection: $selectedGender) {
                            Text("Prefer not to say").tag(Gender.neutral)
                            Text("Male").tag(Gender.male)
                            Text("Female").tag(Gender.female)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Start Button
                Button(action: {
                    showingTest = true
                }) {
                    Text("Take Personality Assessment")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(PersonalityTheme.defaultColors.primary)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
                .disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                Text("This helps us personalize your experience")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 30)
            }
            .padding()
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingTest) {
            PersonalityTestView(username: username, gender: selectedGender)
                .environmentObject(personalityManager)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(PersonalityManager())
}
