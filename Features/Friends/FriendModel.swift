import Foundation
import SwiftUI

struct Friend: Identifiable, Codable {
    let id: UUID
    let name: String
    let personalityType: PersonalityType
    let gender: Gender
    let relationshipType: RelationshipType
    let focusPoints: Int
    let streakDays: Int
    let dailyScreenTimeHours: Double
    let avgSessionLengthMinutes: Int
    let totalFocusHours: Double
    let rank: Int
    
    // New fields for friend management
    let status: FriendStatus
    let addedDate: Date
    let lastActive: Date?
    let isOnline: Bool
    let mutualFriends: Int
    let privacySettings: FriendPrivacySettings?
    
    var personalityColors: PersonalityColors {
        PersonalityTheme.colors(for: personalityType, gender: gender)
    }
    
    var avatarImageName: String {
        PersonalityTheme.mediaName(for: personalityType, gender: gender, isVideo: false)
    }
    
    var formattedDailyScreenTime: String {
        String(format: "%.1f", dailyScreenTimeHours)
    }
    
    var formattedTotalFocusHours: String {
        String(format: "%.1f", totalFocusHours)
    }
    
    // New computed properties
    var isActive: Bool {
        guard let lastActive = lastActive else { return false }
        return Date().timeIntervalSince(lastActive) < 300 // 5 minutes
    }
    
    var friendshipDuration: TimeInterval {
        Date().timeIntervalSince(addedDate)
    }
}

enum RelationshipType: String, Codable, CaseIterable {
    case closeFriend = "close_friend"
    case friend = "friend"
    case acquaintance = "acquaintance"
    
    var displayName: String {
        switch self {
        case .closeFriend: return "Close Friend"
        case .friend: return "Friend"
        case .acquaintance: return "Acquaintance"
        }
    }
}

enum FriendStatus: String, Codable, CaseIterable {
    case pending
    case accepted
    case blocked
}

struct FriendPrivacySettings: Codable {
    let showActivity: Bool
    let allowNudges: Bool
    let showStats: Bool
}

enum FriendRequestStatus: String, Codable, CaseIterable {
    case pending
    case accepted
    case declined
    case cancelled
}

struct FriendRequest: Identifiable, Codable {
    let id: UUID
    let fromUserId: UUID
    let toUserId: UUID
    let fromUserName: String
    let fromUserPersonalityType: PersonalityType
    let fromUserGender: Gender
    let status: FriendRequestStatus
    let createdAt: Date
}


extension Friend {
    static let mockFriends: [Friend] = [
        Friend(
            id: UUID(),
            name: "Alex Chen",
            personalityType: .intj,
            gender: .male,
            relationshipType: .closeFriend,
            focusPoints: 1280,
            streakDays: 14,
            dailyScreenTimeHours: 3.5,
            avgSessionLengthMinutes: 45,
            totalFocusHours: 78.5,
            rank: 1,
            status: .accepted,
            addedDate: Calendar.current.date(byAdding: .day, value: -45, to: Date())!,
            lastActive: Calendar.current.date(byAdding: .minute, value: -2, to: Date()),
            isOnline: true,
            mutualFriends: 8,
            privacySettings: FriendPrivacySettings(showActivity: true, allowNudges: true, showStats: true)
        ),
        Friend(
            id: UUID(),
            name: "Jamie Smith",
            personalityType: .enfp,
            gender: .neutral,
            relationshipType: .friend,
            focusPoints: 980,
            streakDays: 8,
            dailyScreenTimeHours: 5.2,
            avgSessionLengthMinutes: 32,
            totalFocusHours: 65.2,
            rank: 2,
            status: .accepted,
            addedDate: Calendar.current.date(byAdding: .day, value: -28, to: Date())!,
            lastActive: Calendar.current.date(byAdding: .minute, value: -15, to: Date()),
            isOnline: false,
            mutualFriends: 5,
            privacySettings: FriendPrivacySettings(showActivity: true, allowNudges: false, showStats: true)
        ),
        Friend(
            id: UUID(),
            name: "Taylor Wilson",
            personalityType: .istp,
            gender: .female,
            relationshipType: .friend,
            focusPoints: 750,
            streakDays: 5,
            dailyScreenTimeHours: 4.1,
            avgSessionLengthMinutes: 28,
            totalFocusHours: 42.8,
            rank: 3,
            status: .accepted,
            addedDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
            lastActive: Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
            isOnline: false,
            mutualFriends: 3,
            privacySettings: FriendPrivacySettings(showActivity: false, allowNudges: true, showStats: false)
        ),
        Friend(
            id: UUID(),
            name: "Jordan Lee",
            personalityType: .infj,
            gender: .male,
            relationshipType: .acquaintance,
            focusPoints: 620,
            streakDays: 3,
            dailyScreenTimeHours: 6.8,
            avgSessionLengthMinutes: 21,
            totalFocusHours: 36.5,
            rank: 4,
            status: .accepted,
            addedDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            lastActive: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            isOnline: false,
            mutualFriends: 1,
            privacySettings: FriendPrivacySettings(showActivity: false, allowNudges: false, showStats: false)
        ),
        Friend(
            id: UUID(),
            name: "Casey Kim",
            personalityType: .estj,
            gender: .female,
            relationshipType: .friend,
            focusPoints: 540,
            streakDays: 2,
            dailyScreenTimeHours: 7.2,
            avgSessionLengthMinutes: 18,
            totalFocusHours: 28.9,
            rank: 5,
            status: .accepted,
            addedDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            lastActive: Calendar.current.date(byAdding: .minute, value: -30, to: Date()),
            isOnline: false,
            mutualFriends: 2,
            privacySettings: nil
        )
    ]
    
    static let mockFriendRequests: [FriendRequest] = [
        FriendRequest(
            id: UUID(),
            fromUserId: UUID(),
            toUserId: UUID(),
            fromUserName: "Morgan Davis",
            fromUserPersonalityType: .enfj,
            fromUserGender: .neutral,
            status: .pending,
            createdAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        ),
        FriendRequest(
            id: UUID(),
            fromUserId: UUID(),
            toUserId: UUID(),
            fromUserName: "Riley Thompson",
            fromUserPersonalityType: .intp,
            fromUserGender: .female,
            status: .pending,
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        ),
        FriendRequest(
            id: UUID(),
            fromUserId: UUID(),
            toUserId: UUID(),
            fromUserName: "Blake Johnson",
            fromUserPersonalityType: .esfp,
            fromUserGender: .male,
            status: .pending,
            createdAt: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!
        )
    ]
}
