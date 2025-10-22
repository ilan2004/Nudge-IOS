import Foundation

struct EventsService {
    static func post(event type: String, details: [String:String] = [:]) async {
        let userId = UserIdProvider.getOrCreate()
        do { try await APIClient.shared.postEvent(userId: userId, type: type, details: details) }
        catch { /* swallow for now */ }
    }
}

