# MBTI Quiz – iOS Implementation Plan

Status: Approved plan
Owner: iOS
Last updated: 2025-10-21

This document specifies the end-to-end plan to implement the MBTI quiz in the iOS app, aligned with the existing Web UI and Backend.


## Executive decisions (do-what’s-best)

- API base URLs
  - Dev (Simulator): http://127.0.0.1:8000 (allow HTTP only for simulator via ATS exception if needed)
  - Dev (Device): https://api-dev.nudge.starshape.in (or your LAN IP with HTTPS dev tunnel)
  - Staging: https://api-staging.nudge.starshape.in
  - Production: https://api.nudge.starshape.in
  - Notes: Prefer HTTPS everywhere outside simulator; keep CORS locked server-side. Consider future /v1 versioning when server adds it.

- Supabase profile updates from iOS
  - Phase 1 (now, best balance): Local persistence + emit backend event (POST /events/) with the result. No Supabase SDK dependency yet.
  - Phase 2 (optional): If product requires parity, integrate Supabase iOS SDK to mirror the web (update profiles fields test_completed, mbti_type/last_result_mbti).

- Onboarding integration
  - Target: Option B (native onboarding step) to keep one coherent flow: Name → Greeting → Choice → Test → Result → Finish.
  - Rollout: Implement Option A first (modal from ContentView) for speed, then fold into Option B with minimal refactor (we’ll structure components to be re-usable in both flows).

- Question set
  - Use the backend 24 canonical questions (GET /questions/) to ensure string-exact matching for scoring and parity with web.


## Constraints and alignment with Web

- Web UI behavior to match:
  - Likert 1–5 with labels (Strongly Disagree … Strongly Agree).
  - 6 questions per page, vertical centering, smooth scroll to next on answer, progress bar.
  - Validate per-page completion; highlight first missing, haptic nudge; smooth scroll to missing.
  - Submit maps { questionText: 1..5 } exactly as backend expects; backend returns MBTI type & axis scores.
  - Store MBTI locally; (web optionally updates Supabase profile).

- Backend endpoints (current):
  - GET /questions/ → [{ question: string, options: ["Agree","Disagree"] }]
  - POST /answers/ { user_id: string, answers: { [questionText]: 1..5 } } → { user_id, profile: "INTJ", scores: {E,I,S,N,T,F,J,P} }
  - POST /events/ { user_id, event_type, details } (use for analytics like "mbti_completed").


## Architecture and files

- Configuration
  - Info.plist keys: API_BASE_URL (per build config)
  - .xcconfig per environment: inject API_BASE_URL (Dev/Staging/Prod)
  - ATS: allow arbitrary loads ONLY for 127.0.0.1 (simulator) if HTTP used; otherwise require HTTPS.

- Core
  - Core/Networking/APIClient.swift
  - Core/Networking/UserIdProvider.swift (UUID persistence via UserDefaults; optional Keychain wrapper later)
  - Core/Services/EventsService.swift (POST /events/ convenience)

- Features/Onboarding/MBTITest
  - MBTIQuizView.swift (UI)
  - MBTIQuizViewModel.swift (state, fetch, pagination, validation, submit)
  - MBTIResultView.swift (animated reveal)
  - Models: QuestionOut.swift, ProfileResponse.swift

- Integration
  - Option A (initial): Present MBTIQuizView as fullScreenCover from ContentView when onboardingTakeTest is fired.
  - Option B (target): Add a new .test step to OnboardingView and embed MBTIQuizView.


## Data models

```swift path=null start=null
struct QuestionOut: Decodable {
    let question: String
    let options: [String]
}

struct ProfileResponse: Decodable {
    let user_id: String
    let profile: String  // "INTJ"
    let scores: [String:Int]  // E,I,S,N,T,F,J,P
}
```


## Networking

- APIClient (URLSession)
  - Resolves baseURL from Info.plist key API_BASE_URL.
  - GET /questions/ (optionally add user_id as query)
  - POST /answers/ (JSON body)
  - POST /events/ (JSON body)

- Error handling
  - Decode errors into user-friendly messages; retry with backoff for transient failures.

```swift path=null start=null
final class APIClient {
    static let shared = APIClient()
    private let baseURL: URL = {
        guard let s = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              let url = URL(string: s) else { fatalError("Missing API_BASE_URL") }
        return url
    }()
    private let session: URLSession = .shared

    func getQuestions(userId: String?) async throws -> [QuestionOut] {
        var comps = URLComponents(url: baseURL.appendingPathComponent("questions/"), resolvingAgainstBaseURL: false)!
        if let userId { comps.queryItems = [URLQueryItem(name: "user_id", value: userId)] }
        let (data, resp) = try await session.data(from: comps.url!)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode([QuestionOut].self, from: data)
    }

    func postAnswers(userId: String, answers: [String:Int]) async throws -> ProfileResponse {
        var req = URLRequest(url: baseURL.appendingPathComponent("answers/"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: ["user_id": userId, "answers": answers])
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(ProfileResponse.self, from: data)
    }

    func postEvent(userId: String, type: String, details: [String:String]?) async throws {
        var req = URLRequest(url: baseURL.appendingPathComponent("events/"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String:Any] = ["user_id": userId, "event_type": type, "details": details ?? [:]]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
    }
}
```


## User ID strategy

- Generate a UUID once and persist in UserDefaults under key ms_user_id (parity with web naming).
- This is not sensitive; Keychain can be added later if needed for cross-install stability.

```swift path=null start=null
enum UserIdProvider {
    static func getOrCreate() -> String {
        let key = "ms_user_id"
        if let id = UserDefaults.standard.string(forKey: key) { return id }
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: key)
        return id
    }
}
```


## MBTI quiz UI/UX (SwiftUI)

- Layout
  - Header: “Page X of Y”, a progress bar, total count.
  - Body: Paged groups of 6 questions.
    - Each question block: prompt centered; 5 pill buttons with labels.
  - Footer: Back / Next (or Submit on last page).

- Interactions
  - Tap a value: set answer, soft haptic, auto-scroll to next question in the page.
  - Next pressed with missing on page: scroll to first missing, add pulse highlight, warn haptic.
  - Page change: soft haptic; reset scroll to top; briefly fade-in.
  - Submit: build [questionText:Int] using the exact strings from GET /questions/.

- Accessibility
  - VoiceOver labels for scale; Dynamic Type; color contrast; large hit areas.
  - Respect Reduce Motion/Haptics (use UIAccessibility.isReduceMotionEnabled etc.).

- Visual style
  - Use Nudge theme colors (nudgeGreen900, cream surface). Buttons styled as rounded pills consistent with NavPillStyle.


## ViewModel behavior

- State
  - questions: [QuestionOut]
  - answers: [Int:Int] mapping (questionIndex → 1..5); derive questionText during submission.
  - pageIndex, totalPages
  - loading/error flags; isSubmitting

- Logic
  - fetchQuestions(): GET /questions/; keep array order.
  - perPage(index): slice questions by 6s.
  - validatePage(): ensure all 6 answered.
  - findFirstUnansweredGlobal(): used before submit; navigate to its page and focus.
  - submit(): build map [questionText:Int], POST /answers/; handle success/failure.


## Result handling

- On success:
  - Map response.profile (e.g., "INTJ") to PersonalityType enum.
  - PersonalityManager.savePersonalityResult(type:, gender:, scores:)
  - Emit .personalityUpdated
  - Fire EventsService.post("mbti_completed", details: ["type": MBTI])
  - Present MBTIResultView for a quick reveal animation; then dismiss to Home or My Type tab.

- On failure:
  - Keep answers, allow retry, show inline error.


## Integration specifics

- Option A (initial)
  - In ContentView, handle .onboardingTakeTest: set state showMBTIQuiz = true and present MBTIQuizView via .fullScreenCover.
  - On completion: dismiss cover; optionally jump to My Type tab.

- Option B (target)
  - Extend OnboardingView to include a .test step that hosts MBTIQuizView directly in the flow, followed by .result step.


## Analytics & events

- Emit events via POST /events/
  - onboarding_take_test
  - mbti_question_answered (optional, sampled)
  - mbti_page_advance
  - mbti_submitted
  - mbti_completed (with details: { type })


## ATS and environment config

- Info.plist
  - API_BASE_URL string per config.
  - NSAppTransportSecurity: Allow Arbitrary Loads = NO; add ExceptionDomains for 127.0.0.1 only if local HTTP is required for simulator.

- Build configurations
  - Debug: API_BASE_URL = http://127.0.0.1:8000 (sim), alternate config for device = https://api-dev.nudge.starshape.in
  - Staging: API_BASE_URL = https://api-staging.nudge.starshape.in
  - Release: API_BASE_URL = https://api.nudge.starshape.in


## Error states and UX

- Fetch fail: show retry card ("Couldn’t load questions"), allow Cancel (backs out to onboarding choice/home).
- Submit fail: inline error above footer; keep answers; Retry button enabled.
- Empty or malformed questions: defensive check; disable submit.


## Testing strategy

- Unit
  - API decoding for QuestionOut/ProfileResponse
  - ViewModel pagination, per-page validation, global unanswered detection, submission payload correctness (exact strings)
  - UserIdProvider persistence

- UI tests
  - Happy path (answer all, submit, see result)
  - Missing answer highlight and scroll
  - Network errors and retry flows

- Integration (against dev API)
  - Fixed answer set that should consistently yield a known MBTI; assert mapping.


## Performance & polish

- Use ScrollViewReader for precision scrolling to questions.
- Debounce rapid taps; disable double submit while isSubmitting.
- Lightweight animations only; respect Reduce Motion.


## Security & privacy

- No secrets in source. No PII sent besides anonymous user_id (UUID).
- If adding Supabase later, store tokens securely via Keychain.


## Timeline & deliverables

- Day 1
  - APIClient, UserIdProvider, models
  - MBTIQuizViewModel skeleton + fetch
  - FullScreen cover plumbing (Option A)

- Day 2
  - MBTIQuizView UI (page header, 6-per-page, Likert buttons, scroll & haptics)
  - Validation, findFirstUnanswered, submission

- Day 3
  - MBTIResultView (reveal)
  - Events emission, error handling, accessibility pass

- Day 4
  - Tests (unit + basic UI), QA against dev backend
  - Prep for Option B integration path


## Acceptance criteria

- Loads 24 questions from backend and pages them 6 per page.
- Enforces per-page completion with visual + haptic cue; auto-scroll to first missing.
- Submit posts { questionText: 1..5 } with exact backend text, returns MBTI and stores locally via PersonalityManager.
- Emits mbti_completed event.
- Provides a result reveal and returns user to the app with personality applied.


## Risks & mitigations

- String mismatch breaks scoring → Always source questions from GET /questions/ and submit those exact strings.
- HTTP blocked by ATS → Prefer HTTPS; add localhost exception only for simulator; use dev HTTPS for device.
- Supabase parity → Phase 2 opt-in; do not block MBTI ship on this.
- Scroll/haptics feel off → Iterate with small delays + ScrollViewReader; respect Accessibility settings.


## Implementation notes (hooks)

- ContentView: respond to .onboardingTakeTest by presenting MBTIQuizView (Option A), then plan refactor into OnboardingView step (Option B).
- PersonalityManager.savePersonalityResult already updates state and posts .personalityUpdated; reuse it.
- Keep MBTI components self-contained under Features/Onboarding/MBTITest to simplify later reuse from Profile/My Type areas (retake flow).

