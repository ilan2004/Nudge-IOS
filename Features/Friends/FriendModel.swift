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
    
    var personalityColors: PersonalityColors {
        PersonalityTheme.colors(for: personalityType, gender: gender)
    }
    
    var formattedDailyScreenTime: String {
        String(format: "%.1f", dailyScreenTimeHours)
    }
    
    var formattedTotalFocusHours: String {
        String(format: "%.1f", totalFocusHours)
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
            rank: 1
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
            rank: 2
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
            rank: 3
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
            rank: 4
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
            rank: 5
        )
    ]
}
