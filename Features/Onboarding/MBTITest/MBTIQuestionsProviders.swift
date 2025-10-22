import Foundation

struct MBTIAPIQuestionsProvider: MBTIQuestionsProvider {
    func getQuestions() async throws -> [QuestionOut] {
        let userId = UserIdProvider.getOrCreate()
        return try await APIClient.shared.getQuestions(userId: userId)
    }
}

