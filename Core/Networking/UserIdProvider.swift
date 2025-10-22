import Foundation

enum UserIdProvider {
    private static let key = "ms_user_id"

    static func getOrCreate() -> String {
        if let id = UserDefaults.standard.string(forKey: key) { return id }
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: key)
        return id
    }
}

