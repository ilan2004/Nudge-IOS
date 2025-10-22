import SwiftUI
import Combine

// MARK: - Data Models
struct QuestionOut: Codable, Identifiable, Hashable {
    var id: String { question }
    let question: String
    let options: [String]
}

struct ProfileResponse: Codable {
    let user_id: String
    let profile: String
    let scores: [String:Int]
}

// MARK: - Questions Provider
protocol MBTIQuestionsProvider {
    func getQuestions() async throws -> [QuestionOut]
}

// Default mock provider using the canonical 24 items (exact text) so UI works before wiring API
struct MBTIDefaultQuestionsProvider: MBTIQuestionsProvider {
    func getQuestions() async throws -> [QuestionOut] {
        let texts: [String] = [
            // E vs I
            "You gain energy from being around people and external activity.",
            "You prefer discussing ideas out loud rather than reflecting silently.",
            "You are quick to engage and speak up in group settings.",
            "You feel refreshed after spending time alone with your thoughts.",
            "You often think through an idea fully before sharing it.",
            "You prefer a few close friends over a wide circle of acquaintances.",
            // S vs N
            "You rely on concrete facts and past experience when solving problems.",
            "You are attentive to practical details in day-to-day tasks.",
            "You prefer step-by-step instructions over open-ended exploration.",
            "You're drawn to patterns, possibilities, and big-picture connections.",
            "You enjoy brainstorming novel ideas and future scenarios.",
            "You often interpret information beyond what is explicitly stated.",
            // T vs F
            "You prioritize objective criteria over personal values when deciding.",
            "You feel comfortable giving candid, critical feedback when needed.",
            "In debates, you value accuracy more than maintaining harmony.",
            "You consider the impact on people as much as the logic of a decision.",
            "You strive to create consensus and preserve relationships.",
            "You tend to empathize and see multiple personal perspectives.",
            // J vs P
            "You like to plan ahead and close decisions rather than keep options open.",
            "You feel satisfied when tasks are completed well before deadlines.",
            "You prefer clear structure, schedules, and defined expectations.",
            "You enjoy keeping options open and adapting plans as things change.",
            "You're productive in flexible, spontaneous bursts rather than steady routines.",
            "You're comfortable starting before everything is fully defined."
        ]
        return texts.map { QuestionOut(question: $0, options: ["Agree","Disagree"]) }
    }
}

// MARK: - ViewModel
@MainActor
final class MBTIQuizViewModel: ObservableObject {
    // Input / Output
    @Published var questions: [QuestionOut] = []
    @Published var answers: [Int:Int] = [:] // questionIndex -> 1..5
    @Published var pageIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isSubmitting: Bool = false

    // Config
    let pageSize: Int = 6
    private let provider: MBTIQuestionsProvider

    init(provider: MBTIQuestionsProvider = MBTIDefaultQuestionsProvider()) {
        self.provider = provider
    }

    var totalPages: Int { max(1, Int(ceil(Double(questions.count) / Double(pageSize)))) }
    var currentRange: Range<Int> {
        let start = pageIndex * pageSize
        let end = min(start + pageSize, questions.count)
        return start..<end
    }

    var progressFraction: CGFloat {
        guard !questions.isEmpty else { return 0 }
        let answered = answers.keys.count
        return CGFloat(answered) / CGFloat(questions.count)
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let qs = try await provider.getQuestions()
            self.questions = qs
            self.answers = [:]
            self.pageIndex = 0
        } catch {
            self.errorMessage = "Couldn’t load questions. Please try again."
        }
        isLoading = false
    }

    func setAnswer(for questionIndex: Int, value: Int) {
        guard (0..<questions.count).contains(questionIndex), (1...5).contains(value) else { return }
        answers[questionIndex] = value
    }

    func validateCurrentPage() -> Int? {
        for i in currentRange where answers[i] == nil { return i }
        return nil
    }

    func findFirstUnansweredGlobal() -> Int? {
        for i in 0..<questions.count where answers[i] == nil { return i }
        return nil
    }

    func goNext() { if pageIndex + 1 < totalPages { pageIndex += 1 } }
    func goBack() { if pageIndex > 0 { pageIndex -= 1 } }

    func buildSubmissionPayload() -> [String:Int] {
        var map: [String:Int] = [:]
        for (idx, q) in questions.enumerated() {
            if let v = answers[idx] { map[q.question] = v }
        }
        return map
    }
}

