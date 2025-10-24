import SwiftUI

struct FriendsView: View {
    @State private var showDetailOverlay = false
    @State private var selectedFriend: Friend?
    @EnvironmentObject private var personalityManager: PersonalityManager
    
    private var friends: [Friend] {
        Friend.mockFriends.sorted { $0.rank < $1.rank }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Friends")
                        .font(.custom("Tanker-Regular", size: 28))
                        .foregroundColor(Color.guildText)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Add Friend Button
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(personalityManager.currentTheme.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(personalityManager.currentTheme.primary.opacity(0.12))
                                    .overlay(
                                        Capsule().stroke(personalityManager.currentTheme.primary, lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.trailing)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // Friends List
                VStack(spacing: 20) {
                    ForEach(friends.indices, id: \.self) { index in
                        let friend = friends[index]
                        FriendCard(friend: friend, onTap: {
                            selectedFriend = friend
                            showDetailOverlay = true
                        })
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.guildParchment)
                        .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                        .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.nudgeGreen900.opacity(0.25), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: 440)
.sheet(isPresented: $showDetailOverlay) {
            if let friend = selectedFriend {
                FriendDetailOverlay(friend: friend)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FriendsView()
                .environmentObject(PersonalityManager())
        }
    }
}
