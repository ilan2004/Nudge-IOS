import SwiftUI

// MARK: - Leaderboard View
public struct LeaderboardView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Leaderboard")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.green)
            
            Text("Social features coming soon!")
                .foregroundColor(.gray)
            
            // Mock leaderboard
            VStack(spacing: 16) {
                LeaderboardRow(rank: 1, name: "You", score: 1250, isCurrentUser: true)
                LeaderboardRow(rank: 2, name: "Alex", score: 1180, isCurrentUser: false)
                LeaderboardRow(rank: 3, name: "Sarah", score: 1050, isCurrentUser: false)
                LeaderboardRow(rank: 4, name: "Mike", score: 950, isCurrentUser: false)
            }
            .padding()
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
    }
}

public struct LeaderboardRow: View {
    let rank: Int
    let name: String
    let score: Int
    let isCurrentUser: Bool
    @EnvironmentObject var personalityManager: PersonalityManager
    
    public var body: some View {
        HStack {
            Text("#\(rank)")
                .font(.headline)
                .foregroundColor(isCurrentUser ? Color.green : .gray)
                .frame(width: 30)
            
            Text(name)
                .font(.body)
                .fontWeight(isCurrentUser ? .semibold : .regular)
                .foregroundColor(Color.green)
            
            Spacer()
            
            Text("\(score) pts")
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(PersonalityManager())
}
