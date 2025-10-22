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
}

