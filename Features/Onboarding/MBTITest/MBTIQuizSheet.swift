import SwiftUI

// A sheet flow that hosts the quiz and then shows the result reveal
struct MBTIQuizSheet: View {
    @EnvironmentObject var personalityManager: PersonalityManager

    @State private var stage: Stage = .quiz
    @State private var computedType: PersonalityType? = nil
    @State private var isSubmitting = false
    @State private var submitError: String? = nil

    let onFinished: () -> Void

    enum Stage { case quiz, result }

    var body: some View {
        ZStack {
            switch stage {
            case .quiz:
                MBTIQuizView(provider: MBTIFallbackQuestionsProvider()) { payload in
                    Task { await submit(payload: payload) }
                }
            case .result:
                if let t = computedType {
                    MBTIResultView(type: t) {
                        onFinished()
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }

            if isSubmitting {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView("Submitting…")
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
            }
        }
        .alert("Submission failed", isPresented: .constant(submitError != nil), actions: {
            Button("OK") { submitError = nil }
        }, message: { Text(submitError ?? "") })
    }

    @MainActor
    private func submit(payload: [String:Int]) async {
        isSubmitting = true
        submitError = nil
        let userId = UserIdProvider.getOrCreate()
        do {
            let response = try await APIClient.shared.postAnswers(userId: userId, answers: payload)
            if let type = PersonalityType(rawValue: response.profile) {
                personalityManager.savePersonalityResult(type: type, gender: personalityManager.gender, scores: response.scores)
                await EventsService.post(event: "mbti_completed", details: ["type": type.rawValue])
                withAnimation(.spring()) {
                    computedType = type
                    stage = .result
                }
            } else {
                submitError = "Unknown profile returned: \(response.profile)"
            }
        } catch {
            submitError = "Please try again. \(error.localizedDescription)"
        }
        isSubmitting = false
    }
}

#Preview {
    MBTIQuizSheet(onFinished: {})
        .environmentObject(PersonalityManager())
}

