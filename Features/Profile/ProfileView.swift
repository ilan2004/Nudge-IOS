import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    
    var body: some View {
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
                        .foregroundColor(.green)
                    
                    Text(personalityType.rawValue)
                        .font(.custom("Tanker-Regular", size: 20))
                        .foregroundColor(.green)
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
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
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
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.green)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(PersonalityManager())
}
