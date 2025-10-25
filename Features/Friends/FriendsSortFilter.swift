import Foundation

// MARK: - Filter Options

enum FriendFilter: String, CaseIterable {
    case all = "All"
    case closeFriends = "Close Friends"
    case online = "Online"
    case byPersonality = "By Type"
    
    var systemImage: String {
        switch self {
        case .all: return "person.2"
        case .closeFriends: return "heart"
        case .online: return "circle.fill"
        case .byPersonality: return "brain.head.profile"
        }
    }
}

// MARK: - Sort Options

enum FriendSortOption: String, CaseIterable {
    case name = "Name"
    case focusPoints = "Focus Points"
    case streak = "Streak"
    case recentlyAdded = "Recently Added"
    case lastActive = "Last Active"
    
    var systemImage: String {
        switch self {
        case .name: return "textformat.abc"
        case .focusPoints: return "star.fill"
        case .streak: return "flame.fill"
        case .recentlyAdded: return "clock.arrow.2.circlepath"
        case .lastActive: return "clock"
        }
    }
    
    var isDescending: Bool {
        switch self {
        case .name: return false
        case .focusPoints: return true
        case .streak: return true
        case .recentlyAdded: return true
        case .lastActive: return true
        }
    }
}

// MARK: - Array Extensions

extension Array where Element == Friend {
    
    /// Apply filter to friends array
    func filtered(by filter: FriendFilter) -> [Friend] {
        switch filter {
        case .all:
            return self
        case .closeFriends:
            return self.filter { $0.relationshipType == .closeFriend }
        case .online:
            return self.filter { $0.isOnline }
        case .byPersonality:
            // For personality filter, we could group by personality type
            // For now, just return all friends
            return self
        }
    }
    
    /// Apply sort to friends array
    func sorted(by sortOption: FriendSortOption) -> [Friend] {
        switch sortOption {
        case .name:
            return self.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .focusPoints:
            return self.sorted { $0.focusPoints > $1.focusPoints }
        case .streak:
            return self.sorted { $0.streakDays > $1.streakDays }
        case .recentlyAdded:
            return self.sorted { $0.addedDate > $1.addedDate }
        case .lastActive:
            return self.sorted { first, second in
                // Online friends first
                if first.isOnline && !second.isOnline {
                    return true
                } else if !first.isOnline && second.isOnline {
                    return false
                }
                
                // Then by last active time (most recent first)
                guard let firstActive = first.lastActive,
                      let secondActive = second.lastActive else {
                    return first.lastActive != nil
                }
                return firstActive > secondActive
            }
        }
    }
    
    /// Search friends by name
    func matching(query: String) -> [Friend] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return self
        }
        
        let searchQuery = query.lowercased()
        return self.filter { friend in
            friend.name.lowercased().contains(searchQuery) ||
            friend.personalityType.rawValue.lowercased().contains(searchQuery) ||
            friend.relationshipType.displayName.lowercased().contains(searchQuery)
        }
    }
    
    /// Group friends by personality type
    func groupedByPersonality() -> [PersonalityType: [Friend]] {
        return Dictionary(grouping: self) { $0.personalityType }
    }
    
    /// Group friends by relationship type
    func groupedByRelationship() -> [RelationshipType: [Friend]] {
        return Dictionary(grouping: self) { $0.relationshipType }
    }
    
    /// Get only accepted friends
    var acceptedFriends: [Friend] {
        return self.filter { $0.status == .accepted }
    }
    
    /// Get online friends
    var onlineFriends: [Friend] {
        return self.filter { $0.isOnline }
    }
    
    /// Get close friends
    var closeFriends: [Friend] {
        return self.filter { $0.relationshipType == .closeFriend }
    }
}

// MARK: - Helper Functions

/// Format last active date to relative time string
func formatLastActive(_ date: Date?) -> String {
    guard let date = date else {
        return "Last seen unknown"
    }
    
    let interval = Date().timeIntervalSince(date)
    
    if interval < 60 {
        return "Just now"
    } else if interval < 3600 {
        let minutes = Int(interval / 60)
        return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
    } else if interval < 86400 {
        let hours = Int(interval / 3600)
        return "\(hours) hour\(hours == 1 ? "" : "s") ago"
    } else if interval < 604800 { // 7 days
        let days = Int(interval / 86400)
        return "\(days) day\(days == 1 ? "" : "s") ago"
    } else if interval < 2592000 { // 30 days
        let weeks = Int(interval / 604800)
        return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
    } else {
        let months = Int(interval / 2592000)
        return "\(months) month\(months == 1 ? "" : "s") ago"
    }
}

/// Format friendship duration
func formatFriendshipDuration(_ date: Date) -> String {
    let interval = Date().timeIntervalSince(date)
    
    if interval < 86400 { // Less than 1 day
        return "Friends since today"
    } else if interval < 604800 { // Less than 1 week
        let days = Int(interval / 86400)
        return "Friends for \(days) day\(days == 1 ? "" : "s")"
    } else if interval < 2592000 { // Less than 1 month
        let weeks = Int(interval / 604800)
        return "Friends for \(weeks) week\(weeks == 1 ? "" : "s")"
    } else if interval < 31536000 { // Less than 1 year
        let months = Int(interval / 2592000)
        return "Friends for \(months) month\(months == 1 ? "" : "s")"
    } else {
        let years = Int(interval / 31536000)
        return "Friends for \(years) year\(years == 1 ? "" : "s")"
    }
}

/// Format time interval to human readable string
func formatTimeInterval(_ interval: TimeInterval) -> String {
    if interval < 3600 {
        let minutes = Int(interval / 60)
        return "\(minutes)m"
    } else if interval < 86400 {
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        if minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(hours)h"
        }
    } else {
        let days = Int(interval / 86400)
        return "\(days)d"
    }
}

/// Get activity status text for a friend
func getActivityStatus(for friend: Friend) -> String {
    if friend.isOnline {
        return "Active now"
    } else if friend.isActive {
        return "Recently active"
    } else {
        return formatLastActive(friend.lastActive)
    }
}

/// Get activity color for a friend
func getActivityColor(for friend: Friend) -> SystemColor {
    if friend.isOnline {
        return .green
    } else if friend.isActive {
        return .orange
    } else {
        return .secondary
    }
}

// MARK: - System Color Enum for cross-platform compatibility

enum SystemColor {
    case green
    case orange
    case secondary
    case primary
}

// MARK: - Search Suggestions

/// Get search suggestions based on current friends
func getSearchSuggestions(from friends: [Friend]) -> [String] {
    var suggestions = Set<String>()
    
    // Add personality types
    for friend in friends {
        suggestions.insert(friend.personalityType.rawValue)
        suggestions.insert(friend.personalityType.displayName)
    }
    
    // Add relationship types
    for friend in friends {
        suggestions.insert(friend.relationshipType.displayName)
    }
    
    // Add common search terms
    suggestions.insert("online")
    suggestions.insert("offline")
    suggestions.insert("active")
    
    return Array(suggestions).sorted()
}

// MARK: - Statistics

/// Calculate friend statistics
struct FriendStatistics {
    let totalFriends: Int
    let onlineFriends: Int
    let closeFriends: Int
    let totalFocusPoints: Int
    let averageFocusPoints: Int
    let mostActivePersonalityType: PersonalityType?
    let longestFriendship: TimeInterval
    
    init(friends: [Friend]) {
        self.totalFriends = friends.count
        self.onlineFriends = friends.filter { $0.isOnline }.count
        self.closeFriends = friends.filter { $0.relationshipType == .closeFriend }.count
        self.totalFocusPoints = friends.reduce(0) { $0 + $1.focusPoints }
        self.averageFocusPoints = friends.isEmpty ? 0 : totalFocusPoints / friends.count
        
        // Find most common personality type
        let personalityGroups = friends.groupedByPersonality()
        self.mostActivePersonalityType = personalityGroups.max { $0.value.count < $1.value.count }?.key
        
        // Find longest friendship
        self.longestFriendship = friends.map { $0.friendshipDuration }.max() ?? 0
    }
}
