import Foundation

struct UserSearchResult: Identifiable, Codable {
    let id: UUID
    let name: String
    let personalityType: PersonalityType
    let gender: Gender
    let isFriend: Bool
    let hasPendingRequest: Bool
    let focusPoints: Int?
    let mutualFriends: Int
    
    // MARK: - Computed Properties
    
    var avatarImageName: String {
        PersonalityTheme.mediaName(for: personalityType, gender: gender, isVideo: false)
    }
    
    var personalityColors: PersonalityColors {
        PersonalityTheme.colors(for: personalityType, gender: gender)
    }
    
    var canSendRequest: Bool {
        return !isFriend && !hasPendingRequest
    }
    
    var statusText: String {
        if isFriend {
            return "Friend"
        } else if hasPendingRequest {
            return "Pending"
        } else {
            return "Add Friend"
        }
    }
    
    var statusColor: StatusColor {
        if isFriend {
            return .friend
        } else if hasPendingRequest {
            return .pending
        } else {
            return .addable
        }
    }
    
    var displayFocusPoints: String {
        guard let points = focusPoints else { return "N/A" }
        return "\(points)"
    }
    
    var mutualFriendsText: String {
        switch mutualFriends {
        case 0:
            return "No mutual friends"
        case 1:
            return "1 mutual friend"
        default:
            return "\(mutualFriends) mutual friends"
        }
    }
}

// MARK: - Status Color Enum

enum StatusColor {
    case friend
    case pending
    case addable
}

// MARK: - Mock Data

extension UserSearchResult {
    static let mockResults: [UserSearchResult] = [
        UserSearchResult(
            id: UUID(),
            name: "Sarah Chen",
            personalityType: .enfj,
            gender: .female,
            isFriend: false,
            hasPendingRequest: false,
            focusPoints: 1450,
            mutualFriends: 3
        ),
        UserSearchResult(
            id: UUID(),
            name: "Marcus Johnson",
            personalityType: .intj,
            gender: .male,
            isFriend: true,
            hasPendingRequest: false,
            focusPoints: 2100,
            mutualFriends: 5
        ),
        UserSearchResult(
            id: UUID(),
            name: "Luna Rodriguez",
            personalityType: .infp,
            gender: .female,
            isFriend: false,
            hasPendingRequest: true,
            focusPoints: 890,
            mutualFriends: 1
        ),
        UserSearchResult(
            id: UUID(),
            name: "Kai Patel",
            personalityType: .estp,
            gender: .neutral,
            isFriend: false,
            hasPendingRequest: false,
            focusPoints: 1250,
            mutualFriends: 2
        ),
        UserSearchResult(
            id: UUID(),
            name: "Elena Volkov",
            personalityType: .istp,
            gender: .female,
            isFriend: false,
            hasPendingRequest: false,
            focusPoints: 1680,
            mutualFriends: 0
        ),
        UserSearchResult(
            id: UUID(),
            name: "Zara Kim",
            personalityType: .enfp,
            gender: .female,
            isFriend: false,
            hasPendingRequest: true,
            focusPoints: 975,
            mutualFriends: 4
        ),
        UserSearchResult(
            id: UUID(),
            name: "Devon Walsh",
            personalityType: .istj,
            gender: .neutral,
            isFriend: true,
            hasPendingRequest: false,
            focusPoints: 1800,
            mutualFriends: 6
        ),
        UserSearchResult(
            id: UUID(),
            name: "Aria Thompson",
            personalityType: .infj,
            gender: .female,
            isFriend: false,
            hasPendingRequest: false,
            focusPoints: nil,
            mutualFriends: 1
        ),
        UserSearchResult(
            id: UUID(),
            name: "River Nakamura",
            personalityType: .entp,
            gender: .neutral,
            isFriend: false,
            hasPendingRequest: false,
            focusPoints: 1320,
            mutualFriends: 2
        ),
        UserSearchResult(
            id: UUID(),
            name: "Phoenix Okafor",
            personalityType: .esfj,
            gender: .neutral,
            isFriend: false,
            hasPendingRequest: false,
            focusPoints: 1150,
            mutualFriends: 3
        )
    ]
    
    // MARK: - Filtered Mock Results
    
    static var availableToAdd: [UserSearchResult] {
        return mockResults.filter { $0.canSendRequest }
    }
    
    static var currentFriends: [UserSearchResult] {
        return mockResults.filter { $0.isFriend }
    }
    
    static var pendingRequests: [UserSearchResult] {
        return mockResults.filter { $0.hasPendingRequest }
    }
    
    static var highFocusUsers: [UserSearchResult] {
        return mockResults
            .filter { ($0.focusPoints ?? 0) > 1500 }
            .sorted { ($0.focusPoints ?? 0) > ($1.focusPoints ?? 0) }
    }
    
    static var usersWithMutualFriends: [UserSearchResult] {
        return mockResults
            .filter { $0.mutualFriends > 0 }
            .sorted { $0.mutualFriends > $1.mutualFriends }
    }
}

// MARK: - Search and Filter Extensions

extension Array where Element == UserSearchResult {
    
    /// Filter users by search query
    func matching(query: String) -> [UserSearchResult] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return self
        }
        
        let searchQuery = query.lowercased()
        return self.filter { user in
            user.name.lowercased().contains(searchQuery) ||
            user.personalityType.rawValue.lowercased().contains(searchQuery) ||
            user.personalityType.displayName.lowercased().contains(searchQuery)
        }
    }
    
    /// Sort users by relevance (mutual friends, focus points, etc.)
    func sortedByRelevance() -> [UserSearchResult] {
        return self.sorted { first, second in
            // Friends first
            if first.isFriend && !second.isFriend {
                return true
            } else if !first.isFriend && second.isFriend {
                return false
            }
            
            // Then by mutual friends count
            if first.mutualFriends != second.mutualFriends {
                return first.mutualFriends > second.mutualFriends
            }
            
            // Then by focus points (if available)
            let firstPoints = first.focusPoints ?? 0
            let secondPoints = second.focusPoints ?? 0
            if firstPoints != secondPoints {
                return firstPoints > secondPoints
            }
            
            // Finally by name
            return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
        }
    }
    
    /// Filter by friendship status
    func filtered(by status: FriendshipStatus) -> [UserSearchResult] {
        switch status {
        case .all:
            return self
        case .friends:
            return self.filter { $0.isFriend }
        case .pending:
            return self.filter { $0.hasPendingRequest }
        case .available:
            return self.filter { $0.canSendRequest }
        }
    }
}

// MARK: - Supporting Enums

enum FriendshipStatus: String, CaseIterable {
    case all = "All"
    case friends = "Friends"
    case pending = "Pending"
    case available = "Available"
    
    var systemImage: String {
        switch self {
        case .all: return "person.2"
        case .friends: return "person.2.fill"
        case .pending: return "clock"
        case .available: return "person.badge.plus"
        }
    }
}

// MARK: - Hashable Conformance

extension UserSearchResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: UserSearchResult, rhs: UserSearchResult) -> Bool {
        return lhs.id == rhs.id
    }
}
