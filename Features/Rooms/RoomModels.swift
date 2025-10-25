import Foundation

// MARK: - Room Models

struct Room: Identifiable, Codable {
    let id: UUID
    var name: String? = "Focus Room"
    let creatorId: UUID
    var memberIds: [UUID]
    var schedule: RoomSchedule
    var isActive: Bool
    let createdAt: Date
    var currentSessionId: UUID?
}

struct RoomMember: Identifiable, Codable {
    let id: UUID // friend ID
    let friend: Friend
    var sessionStats: RoomSessionStats
    var isOnline: Bool
}

struct RoomSchedule: Codable {
    var startTime: Date // time-of-day
    var endTime: Date   // time-of-day
    var daysOfWeek: Set<Int> // 0-6 (Sun-Sat)
    var isRecurring: Bool
    var timezone: TimeZone
}

struct RoomSessionStats: Codable {
    let userId: UUID
    var focusTimeSeconds: Int
    var breakCount: Int
    var screenTimeSeconds: Int
    var distractionCount: Int
    var lastUpdated: Date
}

struct RoomSession: Identifiable, Codable {
    let id: UUID
    let roomId: UUID
    let startTime: Date
    var endTime: Date?
    var memberStats: [UUID: RoomSessionStats] // keyed by user ID
    var isCompleted: Bool
}

// MARK: - Mock Data
extension Room {
    static func makeMockSchedule(startHour: Int = 9, endHour: Int = 10, tz: TimeZone = .current, days: Set<Int> = [1,2,3,4,5], recurring: Bool = true) -> RoomSchedule {
        let cal = Calendar.current
        let now = Date()
        let start = cal.date(bySettingHour: startHour, minute: 0, second: 0, of: now) ?? now
        let end = cal.date(bySettingHour: endHour, minute: 0, second: 0, of: now) ?? now.addingTimeInterval(3600)
        return RoomSchedule(startTime: start, endTime: end, daysOfWeek: days, isRecurring: recurring, timezone: tz)
    }

    static let mockMembers: [RoomMember] = {
        let friends = Array(Friend.mockFriends.prefix(3))
        return friends.map { f in
            RoomMember(
                id: f.id,
                friend: f,
                sessionStats: RoomSessionStats(
                    userId: f.id,
                    focusTimeSeconds: Int.random(in: 600...3600),
                    breakCount: Int.random(in: 0...3),
                    screenTimeSeconds: Int.random(in: 300...2400),
                    distractionCount: Int.random(in: 0...6),
                    lastUpdated: Date()
                ),
                isOnline: Bool.random()
            )
        }
    }()

    static let mockRooms: [Room] = {
        let members = mockMembers
        let creator = members.first?.id ?? UUID()
        let schedule = makeMockSchedule()
        let room = Room(
            id: UUID(),
            name: "Morning Focus Room",
            creatorId: creator,
            memberIds: members.map { $0.id },
            schedule: schedule,
            isActive: true,
            createdAt: Date().addingTimeInterval(-86400),
            currentSessionId: nil
        )
        return [room]
    }()
}

extension RoomSession {
    static func mock(for room: Room, members: [RoomMember] = Room.mockMembers) -> RoomSession {
        let start = Date().addingTimeInterval(-1800)
        let stats = Dictionary(uniqueKeysWithValues: members.map { m in
            (m.id, RoomSessionStats(
                userId: m.id,
                focusTimeSeconds: Int.random(in: 300...1800),
                breakCount: Int.random(in: 0...2),
                screenTimeSeconds: Int.random(in: 120...1200),
                distractionCount: Int.random(in: 0...4),
                lastUpdated: Date()
            ))
        })
        return RoomSession(
            id: UUID(),
            roomId: room.id,
            startTime: start,
            endTime: nil,
            memberStats: stats,
            isCompleted: false
        )
    }
}

// MARK: - API Serialization Extensions
extension RoomSchedule {
    func toDictionary() throws -> [String: Any] {
        let formatter = ISO8601DateFormatter()
        return [
            "start_time": formatter.string(from: startTime),
            "end_time": formatter.string(from: endTime),
            "days_of_week": Array(daysOfWeek),
            "is_recurring": isRecurring,
            "timezone": timezone.identifier
        ]
    }
}

extension RoomSessionStats {
    func toDictionary() throws -> [String: Any] {
        let formatter = ISO8601DateFormatter()
        return [
            "user_id": userId.uuidString,
            "focus_time_seconds": focusTimeSeconds,
            "break_count": breakCount,
            "screen_time_seconds": screenTimeSeconds,
            "distraction_count": distractionCount,
            "last_updated": formatter.string(from: lastUpdated)
        ]
    }
}

