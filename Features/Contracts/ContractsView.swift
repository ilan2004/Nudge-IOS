import SwiftUI

// MARK: - Contracts View
public struct ContractsView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Contracts")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.green)
            
            Text("Accountability system coming soon!")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContractsView()
        .environmentObject(PersonalityManager())
}
