import Foundation

struct MBTIAPIQuestionsProvider: MBTIQuestionsProvider {
    func getQuestions() async throws -> [QuestionOut] {
        let userId = UserIdProvider.getOrCreate()
        return try await APIClient.shared.getQuestions(userId: userId)
    }
}

struct MBTIFallbackQuestionsProvider: MBTIQuestionsProvider {
    let api = MBTIAPIQuestionsProvider()
    let local = MBTIDefaultQuestionsProvider()
    
    func getQuestions() async throws -> [QuestionOut] {
        // Try API first
        if let result = try? await api.getQuestions(), result.isEmpty == false {
            return result
        }
        // Fallback to bundled set
        return try await local.getQuestions()
    }
}

