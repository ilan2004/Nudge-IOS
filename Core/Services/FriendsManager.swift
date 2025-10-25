import SwiftUI
import Combine

@MainActor
class FriendsManager: ObservableObject {
    // MARK: - Published Properties
    @Published var friends: [Friend] = []
    @Published var pendingRequests: [FriendRequest] = []
    @Published var sentRequests: [FriendRequest] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchResults: [UserSearchResult] = []
    
    // MARK: - Private Properties
    private let apiClient: APIClient
    private let userIdProvider: UserIdProvider.Type
    
    // MARK: - UserDefaults Keys
    private let friendsKey = "nudge_friends"
    private let pendingRequestsKey = "nudge_pending_requests"
    private let sentRequestsKey = "nudge_sent_requests"
    
    // MARK: - Initialization
    init(apiClient: APIClient = .shared, userIdProvider: UserIdProvider.Type = UserIdProvider.self) {
        self.apiClient = apiClient
        self.userIdProvider = userIdProvider
        
        loadFriendsFromCache()
    }
    
    // MARK: - Public Methods
    
    /// Load friends from API and cache locally
    func loadFriends() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let userId = userIdProvider.getOrCreate()
            let fetchedFriends = try await apiClient.getFriends(userId: userId)
            
            friends = fetchedFriends
            saveFriendsToCache()
        } catch {
            errorMessage = "Failed to load friends: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Load friend requests from API
    func loadFriendRequests() async throws {
        do {
            let userId = userIdProvider.getOrCreate()
            let requests = try await apiClient.getFriendRequests(userId: userId)
            
            // Separate incoming and outgoing requests
            let currentUserId = UUID(uuidString: userId) ?? UUID()
            pendingRequests = requests.filter { $0.toUserId == currentUserId }
            sentRequests = requests.filter { $0.fromUserId == currentUserId }
            
            savePendingRequestsToCache()
        } catch {
            errorMessage = "Failed to load friend requests: \(error.localizedDescription)"
            throw error
        }
    }
    
    /// Send friend request
    func sendFriendRequest(toUserId: UUID) async throws {
        do {
            let userId = userIdProvider.getOrCreate()
            let request = try await apiClient.sendFriendRequest(
                userId: userId,
                targetUserId: toUserId.uuidString
            )
            
            sentRequests.append(request)
            savePendingRequestsToCache()
        } catch {
            errorMessage = "Failed to send friend request: \(error.localizedDescription)"
            throw error
        }
    }
    
    /// Accept friend request
    func acceptFriendRequest(requestId: UUID) async throws {
        do {
            let userId = userIdProvider.getOrCreate()
            let newFriend = try await apiClient.acceptFriendRequest(
                userId: userId,
                requestId: requestId.uuidString
            )
            
            // Add to friends list
            friends.append(newFriend)
            saveFriendsToCache()
            
            // Remove from pending requests
            pendingRequests.removeAll { $0.id == requestId }
            savePendingRequestsToCache()
        } catch {
            errorMessage = "Failed to accept friend request: \(error.localizedDescription)"
            throw error
        }
    }
    
    /// Decline friend request
    func declineFriendRequest(requestId: UUID) async throws {
        do {
            let userId = userIdProvider.getOrCreate()
            try await apiClient.declineFriendRequest(
                userId: userId,
                requestId: requestId.uuidString
            )
            
            // Remove from pending requests
            pendingRequests.removeAll { $0.id == requestId }
            savePendingRequestsToCache()
        } catch {
            errorMessage = "Failed to decline friend request: \(error.localizedDescription)"
            throw error
        }
    }
    
    /// Remove friend
    func removeFriend(friendId: UUID) async throws {
        do {
            let userId = userIdProvider.getOrCreate()
            try await apiClient.removeFriend(
                userId: userId,
                friendId: friendId.uuidString
            )
            
            // Remove from friends list
            friends.removeAll { $0.id == friendId }
            saveFriendsToCache()
        } catch {
            errorMessage = "Failed to remove friend: \(error.localizedDescription)"
            throw error
        }
    }
    
    /// Search for users
    func searchUsers(query: String) async throws {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        do {
            let userId = userIdProvider.getOrCreate()
            let results = try await apiClient.searchUsers(userId: userId, query: query)
            searchResults = results
        } catch {
            errorMessage = "Failed to search users: \(error.localizedDescription)"
            throw error
        }
    }
    
    /// Send nudge to friend
    func sendNudge(toFriendId: UUID, message: String?) async throws {
        do {
            let userId = userIdProvider.getOrCreate()
            try await apiClient.sendNudgeToFriend(
                userId: userId,
                friendId: toFriendId.uuidString,
                message: message
            )
        } catch {
            errorMessage = "Failed to send nudge: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Caching Methods
    
    private func loadFriendsFromCache() {
        if let data = UserDefaults.standard.data(forKey: friendsKey),
           let cachedFriends = try? JSONDecoder().decode([Friend].self, from: data) {
            friends = cachedFriends
        }
        
        if let data = UserDefaults.standard.data(forKey: pendingRequestsKey),
           let cachedRequests = try? JSONDecoder().decode([FriendRequest].self, from: data) {
            let currentUserId = UUID(uuidString: userIdProvider.getOrCreate()) ?? UUID()
            pendingRequests = cachedRequests.filter { $0.toUserId == currentUserId }
            sentRequests = cachedRequests.filter { $0.fromUserId == currentUserId }
        }
    }
    
    private func saveFriendsToCache() {
        if let data = try? JSONEncoder().encode(friends) {
            UserDefaults.standard.set(data, forKey: friendsKey)
        }
    }
    
    private func savePendingRequestsToCache() {
        let allRequests = pendingRequests + sentRequests
        if let data = try? JSONEncoder().encode(allRequests) {
            UserDefaults.standard.set(data, forKey: pendingRequestsKey)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Find friend by ID
    func getFriend(byId friendId: UUID) -> Friend? {
        return friends.first { $0.id == friendId }
    }
    
    /// Check friendship status
    func isFriend(userId: UUID) -> Bool {
        return friends.contains { $0.id == userId }
    }
    
    /// Get pending request count for badge
    func getPendingRequestCount() -> Int {
        return pendingRequests.count
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Clear search results
    func clearSearchResults() {
        searchResults = []
    }
    
    // MARK: - Computed Properties
    
    /// Get accepted friends only
    var acceptedFriends: [Friend] {
        return friends.filter { $0.status == .accepted }
    }
    
    /// Get close friends
    var closeFriends: [Friend] {
        return acceptedFriends.filter { $0.relationshipType == .closeFriend }
    }
    
    /// Get online friends
    var onlineFriends: [Friend] {
        return acceptedFriends.filter { $0.isOnline }
    }
}
