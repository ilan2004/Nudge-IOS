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
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Add Friend Button
                    Button(action: {}) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(personalityManager.personalityColors.primary)
                    }
                    .padding(.trailing)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // Friends List
                VStack(spacing: 16) {
                    ForEach(friends) { friend in
                        FriendCard(friend: friend) {
                            selectedFriend = friend
                            showDetailOverlay = true
                        }
                        .padding(.horizontal)
                    }
                }
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
