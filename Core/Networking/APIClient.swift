import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let session: URLSession = .shared

    private var baseURL: URL {
        if let s = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           let url = URL(string: s), url.scheme != nil {
            return url
        }
        // Fallback for dev to avoid crashes when key is missing or not expanded
        return URL(string: "http://127.0.0.1:8000")!
    }

    // GET /questions/
    func getQuestions(userId: String?) async throws -> [QuestionOut] {
        var url = baseURL.appendingPathComponent("questions/")
        if let userId, var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            comps.queryItems = [URLQueryItem(name: "user_id", value: userId)]
            url = comps.url ?? url
        }
        let (data, resp) = try await session.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([QuestionOut].self, from: data)
    }

    // POST /answers/
    func postAnswers(userId: String, answers: [String:Int]) async throws -> ProfileResponse {
        var req = URLRequest(url: baseURL.appendingPathComponent("answers/"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["user_id": userId, "answers": answers]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(ProfileResponse.self, from: data)
    }

    // POST /events/
    func postEvent(userId: String, type: String, details: [String:String] = [:]) async throws {
        var req = URLRequest(url: baseURL.appendingPathComponent("events/"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "user_id": userId,
            "event_type": type,
            "details": details
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Room Endpoints
    
    // GET /rooms/
    func getRooms(userId: String) async throws -> [Room] {
        var url = baseURL.appendingPathComponent("rooms/")
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "user_id", value: userId)]
        url = comps.url!
        
        let (data, resp) = try await session.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([Room].self, from: data)
    }
    
    // POST /rooms/
    func createRoom(userId: String, name: String?, memberIds: [String], schedule: RoomSchedule) async throws -> Room {
        var req = URLRequest(url: baseURL.appendingPathComponent("rooms/"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_id": userId,
            "name": name as Any,
            "member_ids": memberIds,
            "schedule": try schedule.toDictionary()
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(Room.self, from: data)
    }
    
    // PUT /rooms/{roomId}
    func updateRoom(roomId: String, name: String?, schedule: RoomSchedule?) async throws -> Room {
        var req = URLRequest(url: baseURL.appendingPathComponent("rooms/\(roomId)"))
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [:]
        if let name = name {
            body["name"] = name
        }
        if let schedule = schedule {
            body["schedule"] = try schedule.toDictionary()
        }
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(Room.self, from: data)
    }
    
    // DELETE /rooms/{roomId}
    func deleteRoom(roomId: String) async throws {
        var req = URLRequest(url: baseURL.appendingPathComponent("rooms/\(roomId)"))
        req.httpMethod = "DELETE"
        
        let (_, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    // POST /rooms/{roomId}/sessions/start
    func startRoomSession(roomId: String, userId: String) async throws -> RoomSession {
        var req = URLRequest(url: baseURL.appendingPathComponent("rooms/\(roomId)/sessions/start"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["user_id": userId]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(RoomSession.self, from: data)
    }
    
    // POST /rooms/{roomId}/sessions/{sessionId}/end
    func endRoomSession(roomId: String, sessionId: String, userId: String, stats: RoomSessionStats) async throws -> RoomSession {
        var req = URLRequest(url: baseURL.appendingPathComponent("rooms/\(roomId)/sessions/\(sessionId)/end"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_id": userId,
            "stats": try stats.toDictionary()
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(RoomSession.self, from: data)
    }
    
    // GET /rooms/{roomId}/sessions/{sessionId}/stats
    func getSessionStats(roomId: String, sessionId: String) async throws -> [String: RoomSessionStats] {
        let url = baseURL.appendingPathComponent("rooms/\(roomId)/sessions/\(sessionId)/stats")
        
        let (data, resp) = try await session.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // Decode as dictionary with string keys (UUID strings)
        let rawDict = try JSONDecoder().decode([String: RoomSessionStats].self, from: data)
        return rawDict
    }
    
    // POST /rooms/{roomId}/sessions/{sessionId}/stats
    func updateSessionStats(roomId: String, sessionId: String, userId: String, stats: RoomSessionStats) async throws {
        var req = URLRequest(url: baseURL.appendingPathComponent("rooms/\(roomId)/sessions/\(sessionId)/stats"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_id": userId,
            "stats": try stats.toDictionary()
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

