import SwiftUI


struct FriendsView: View {
    @EnvironmentObject private var friendsManager: FriendsManager
    @EnvironmentObject private var personalityManager: PersonalityManager
    
    @State private var showDetailOverlay = false
    @State private var selectedFriend: Friend?
    @State private var showAddFriendSheet = false
    @State private var showRequestsSheet = false
    @State private var searchQuery = ""
    @State private var selectedFilter: FriendFilter = .all
    
    private var filteredFriends: [Friend] {
        var friends = friendsManager.acceptedFriends
        
        // Apply search filter
        if !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            friends = friends.filter { friend in
                friend.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        // Apply selected filter
        switch selectedFilter {
        case .all:
            break
        case .closeFriends:
            friends = friends.filter { $0.relationshipType == .closeFriend }
        case .online:
            friends = friends.filter { $0.isOnline }
        case .byPersonality:
            // For now, just return all friends (could implement personality grouping later)
            break
        }
        
        return friends.sorted { $0.rank < $1.rank }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                searchBarView
                filterChipsView
                contentView
            }
        }
        .frame(maxWidth: 440)
        .refreshable {
            do {
                async let friendsLoad: Void = friendsManager.loadFriends()
                async let requestsLoad: Void = friendsManager.loadFriendRequests()
                try await friendsLoad
                try await requestsLoad
            } catch {
                // Error handling is done in FriendsManager
            }
        }
        .sheet(isPresented: $showDetailOverlay) {
            if let friend = selectedFriend {
                FriendDetailOverlay(friend: friend)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showAddFriendSheet) {
            AddFriendView()
                .environmentObject(friendsManager)
                .environmentObject(personalityManager)
        }
        .sheet(isPresented: $showRequestsSheet) {
            FriendRequestsView()
                .environmentObject(friendsManager)
                .environmentObject(personalityManager)
        }
    }
    
    // MARK: - Helper Methods
    
    private func variantForFilter(_ filter: FriendFilter) -> PillVariant {
        switch filter {
        case .all:
            return .primary
        case .closeFriends:
            return .accent
        case .online:
            return .cyan
        case .byPersonality:
            return .amber
        }
    }
    
    // MARK: - Extracted Views
    
    private var headerView: some View {
        HStack {
            Text("Friends")
                .font(.custom("Tanker-Regular", size: 28))
                .foregroundColor(Color.guildText)
                .padding(.horizontal)
            
            Spacer()
            
            // Friend Requests Button with Badge
            if friendsManager.getPendingRequestCount() > 0 {
                Button(action: { showRequestsSheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.badge.plus")
                            .font(.caption)
                        Text("\(friendsManager.getPendingRequestCount())")
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.red)
                    )
                }
                .padding(.trailing, 8)
            }
            
            // Add Friend Button
            Button(action: { showAddFriendSheet = true }) {
                Image(systemName: "plus")
                    .font(.headline)
            }
            .buttonStyle(NavPillStyle(variant: .primary))
            .padding(.trailing)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search friends...", text: $searchQuery)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96)))
                .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.nudgeGreen900, lineWidth: 2)
        )
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FriendFilter.allCases, id: \.self) { filter in
                    Button(filter.rawValue) {
                        selectedFilter = filter
                    }
                    .buttonStyle(NavPillStyle(variant: selectedFilter == filter ? variantForFilter(filter) : .outline, compact: true))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .padding(.bottom, 16)
    }
    
    private var contentView: some View {
        Group {
            if friendsManager.isLoading {
                loadingView
            } else if let errorMessage = friendsManager.errorMessage {
                errorView(errorMessage)
            } else if filteredFriends.isEmpty {
                emptyStateView
            } else {
                friendsListView
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Text("Loading friends...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .retroConsoleSurface()
        .padding(.horizontal)
        .padding(.bottom, 24)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            Text("Error")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task {
                    try? await friendsManager.loadFriends()
                }
            }
            .buttonStyle(NavPillStyle(variant: .primary))
        }
        .padding(16)
        .retroConsoleSurface()
        .padding(.horizontal)
        .padding(.bottom, 24)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 48))
                .foregroundColor(personalityManager.currentTheme.secondary.opacity(0.8))
            
            if friendsManager.friends.isEmpty {
                Text("No Friends Yet")
                    .font(.headline)
                    .foregroundColor(personalityManager.currentTheme.text)
                Text("Add friends to start collaborating!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Button("Add Friends") {
                    showAddFriendSheet = true
                }
                .buttonStyle(NavPillStyle(variant: .primary))
            } else {
                Text("No friends match your search")
                    .font(.headline)
                    .foregroundColor(personalityManager.currentTheme.text)
                Button("Clear Search") {
                    searchQuery = ""
                    selectedFilter = .all
                }
                .buttonStyle(NavPillStyle(variant: .outline))
            }
        }
        .padding(16)
        .retroConsoleSurface()
        .padding(.horizontal)
        .padding(.bottom, 24)
    }
    
    private var friendsListView: some View {
        VStack(spacing: 20) {
            ForEach(filteredFriends.indices, id: \.self) { index in
                let friend = filteredFriends[index]
                FriendCard(friend: friend, onTap: {
                    selectedFriend = friend
                    showDetailOverlay = true
                })
            }
        }
        .padding(12)
        .retroConsoleSurface()
        .padding(.horizontal)
        .padding(.bottom, 24)
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FriendsView()
                .environmentObject(FriendsManager(useMockData: true))
                .environmentObject(PersonalityManager())
        }
    }
}
