# Onboarding Plan

## Goals
- Smooth first-run experience with brand splash, intro messages, name capture, and optional MBTI test.
- Reusable services for haptics, typewriter animation, persistence, and MBTI scoring.
- Clean separation via SwiftUI + MVVM + Coordinator.

## User Flow (first run)
1) Splash: Show logo + app name every launch (short).  
2) Intro: Typewriter tips about the app with subtle haptics.  
3) Name entry: Ask how the app should address the user; typewriter input + per-letter haptic.  
4) Choice: “Skip & Start Blocking” → Home OR “Take MBTI Test” → 30 Qs → Result → Finish → Home.  

Subsequent launches: Skip to Home (unless onboarding incomplete).

## Directory & File Structure
```
nudge-ios/
  App/
    NudgeApp.swift
    AppCoordinator.swift
    RootView.swift
  Core/
    Feedback/
      HapticsService.swift            // Light/medium/heavy, configurable
    Persistence/
      KeyValueStore.swift             // Wraps UserDefaults
      OnboardingStateStore.swift      // hasSeenIntro, hasEnteredName, hasCompletedOnboarding, mbtiType
    UI/
      Theme/
        Colors.swift
        Typography.swift
        Spacing.swift
      Components/
        PrimaryButton.swift
        SecondaryButton.swift
        ProgressDots.swift
        CardContainer.swift
        SafeAreaContainer.swift
  Features/
    Onboarding/
      OnboardingCoordinator.swift     // Drives flow: Splash -> Intro -> Name -> Choice -> Test -> Result/Finish
      OnboardingRoute.swift
      Models/
        IntroMessage.swift
        MBTIQuestion.swift
        MBTIAnswer.swift
        MBTIType.swift
      Services/
        MBTIService.swift             // Scoring logic
        TypewriterEngine.swift        // Timing, per-char callbacks for haptics
      Components/
        TypewriterText.swift
        HapticTypingOverlay.swift
        SkipButton.swift
      Splash/
        SplashView.swift
        SplashViewModel.swift
      Intro/
        IntroView.swift               // Typewriter tips + subtle haptics
        IntroViewModel.swift
      NameEntry/
        NameEntryView.swift           // Typewriter reveal + per-letter haptic
        NameEntryViewModel.swift
      Choice/
        OnboardingChoiceView.swift    // “Skip & Start Blocking” or “Take MBTI Test”
        OnboardingChoiceViewModel.swift
      MBTITest/
        MBTITestView.swift            // 30 Qs, progress, back/next
        MBTITestViewModel.swift
        MBTIResultView.swift          // Declares type, CTA to finish
      Data/
        mbti_questions.json
    Home/
      HomeView.swift
      HomeViewModel.swift
  Resources/
    Assets.xcassets                   // App logo, onboarding illustrations
    Fonts/
    Lottie/
    Localizable.strings
  Tests/
    OnboardingTests/
      OnboardingCoordinatorTests.swift
      MBTIServiceTests.swift
      TypewriterEngineTests.swift
      NameEntryViewModelTests.swift
```

## State & Persistence
- OnboardingStateStore (backed by KeyValueStore):
  - hasSeenSplash: Bool
  - hasSeenIntro: Bool
  - hasEnteredName: Bool
  - userName: String?
  - hasCompletedOnboarding: Bool
  - mbtiType: MBTIType?
- Keys (example): `onboarding.hasSeenIntro`, `onboarding.userName`, `onboarding.mbtiType`, `onboarding.completed`.

## Navigation
- OnboardingCoordinator selects the next screen based on OnboardingStateStore.  
- Routes: Splash → Intro → Name → Choice → (Skip→Home | Test→Questions→Result→Finish→Home).

## Services
- HapticsService
  - API: impact(style: .light/.medium/.heavy), selection(), notify(success/warning/error)
  - Per-character callbacks for typing scenarios.
- TypewriterEngine
  - Inputs: text, speed, perChar callback, completion.
  - Emits per-character ticks to drive haptics and UI updates.
- MBTIService
  - Input: [MBTIQuestion] with weighted answers mapping to dichotomies (E/I, S/N, T/F, J/P).
  - Output: MBTIType (e.g., "INTJ") with optional trait scores for UI.

## Views (SwiftUI + MVVM)
- SplashView: shows logo + app name, times out or taps through.
- IntroView: renders sequence of IntroMessage items with typewriter effect and subtle haptics.
- NameEntryView: user provides preferred name; typewriter reveal on confirm.
- OnboardingChoiceView: primary CTA “Skip & Start Blocking”, secondary CTA “Take MBTI Test”.
- MBTITestView: 30 questions, progress indicator, back/next, persists partial state.
- MBTIResultView: shows MBTI type, brief description, finish button sets completion.

## Data
- `mbti_questions.json` shape example:
```
[
  {
    "id": 1,
    "prompt": "You find it easy to introduce yourself to other people.",
    "answers": [
      { "label": "Strongly Disagree", "weights": { "E": -2, "I": 2 } },
      { "label": "Disagree",          "weights": { "E": -1, "I": 1 } },
      { "label": "Neutral",           "weights": { } },
      { "label": "Agree",             "weights": { "E": 1,  "I": -1 } },
      { "label": "Strongly Agree",    "weights": { "E": 2,  "I": -2 } }
    ]
  }
]
```

## Assets & Localization
- Assets.xcassets: app logo, onboarding illustrations, MBTI result icons.
- Localizable.strings: copy for intro messages, prompts, buttons, error states.
- Fonts (optional custom), Lottie animations (optional for splash/intro embellishment).

## Accessibility & Haptics Considerations
- Respect Reduce Motion / Reduce Haptics system settings; provide in-app toggle to disable.
- Ensure VoiceOver reads typewriter content sensibly (announce full line after completion).
- Sufficient color contrast and large tap targets for CTAs.

## Analytics (optional)
- Track key funnel events: open_splash, intro_finished, name_entered, choice_skip, choice_test, test_completed, onboarding_completed.

## Milestones
1) Scaffolding: folders, coordinator, state, services stubs.  
2) Splash + Intro (typewriter + subtle haptics).  
3) Name Entry (typewriter confirm + per-letter haptic).  
4) Choice screen + skip path to Home.  
5) MBTI test: data, UI, scoring, result screen.  
6) Polish: persistence edge cases, accessibility, localization, animations.

