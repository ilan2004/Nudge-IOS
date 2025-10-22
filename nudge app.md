# 🧠 Nudge — Concept Overview

Nudge is a gamified productivity app that personalizes focus using your MBTI personality type.

“Focus isn’t one-size-fits-all — it’s personal.”

Instead of enforcing rigid productivity systems, Nudge adapts to you — how your mind works, how you recharge, and how you stay on track.

---

## ⚙️ Core Mechanics (How It Works)

### 1) Character Selection (MBTI Integration)
- The MBTI personality quiz becomes a “character selection” moment — like starting a game.
- The test assigns one of 16 MBTI types, a character avatar, and a personality profile.
- Your character influences:
  - UI theme
  - Motivational nudges
  - Focus flow
  - Data visualization

### 2) Smart Blocking (Distraction Control Engine)
- Integrates with OS-level blocking APIs to reduce distractions during focus mode:
  - iOS: FamilyControls framework
  - Android: UsageStats + Accessibility permissions
- During focus mode, selected apps (e.g., Instagram, YouTube) are blocked.

### 3) Focus Sessions & Gamified Scoring
- Modes:
  - Solo focus sessions
  - Group focus challenges
- Each session tracks:
  - Total Focus Time ⏱️
  - Breaks taken
  - Distraction attempts
  - Consistency streaks
- Generates Focus Points to build your profile and level up your character.
- Social features:
  - Compete with friends for top focus scores
  - Collaborate in shared focus sessions
  - Real-time Leaderboard
- Goal: subtle social incentive — competition without pressure.

### 4) Profile Dashboard
- Shows:
  - Personality Type & Character Avatar
  - Total Focus Hours
  - Focus Points & Weekly Trends
  - Active Streaks
  - Leaderboard Rank among friends
- Feels like a personal stats screen for real-life focus.

### 5) Visual & Emotional Feedback
- Clean, theme-based visuals that change with your MBTI type.
- Micro animations when milestones hit (e.g., “Flow Unlocked”).
- Mood-based background shifts (e.g., sunset tones near session completion).
- Outcome: emotional resonance with every focus win.

### 6) Underground Mode (Privacy / Stealth Layer)
- “Private training mode” for silent progress.
- Hides focus hours and points from public leaderboards.
- Still shows screen time for self-accountability.
- You continue accumulating Focus XP internally.
- Visibility can be toggled back on anytime.
- Designed for introverts, private achievers, and anyone who prefers control without isolation.

## Mock Data — Friends

### Data Schema
```swift
struct Friend: Identifiable, Codable {
    let id: UUID
    let name: String
    let personalityType: PersonalityType  // ENUM: One of 16 MBTI types (e.g., .intj, .enfp)
    let gender: Gender                    // ENUM: .male, .female, .nonBinary
    let relationshipType: RelationshipType // ENUM: .closeFriend, .friend, .acquaintance
    let focusPoints: Int                  // Total focus points earned
    let streakDays: Int                   // Current streak in days
    let dailyScreenTimeHours: Double      // Average daily screen time
    let avgSessionLengthMinutes: Int      // Average focus session length
    let totalFocusHours: Double           // Total lifetime focus hours
    let rank: Int                         // Leaderboard position
}
```

### Sample Data
```swift
static let mockFriends: [Friend] = [
    // Close friend - High performer
    Friend(
        id: UUID(),
        name: "Alex Chen",
        personalityType: .intj,
        gender: .male,
        relationshipType: .closeFriend,
        focusPoints: 1280,
        streakDays: 14,
        dailyScreenTimeHours: 3.5,
        avgSessionLengthMinutes: 45,
        totalFocusHours: 78.5,
        rank: 1
    ),
    
    // Friend - Balanced user
    Friend(
        id: UUID(),
        name: "Jamie Smith",
        personalityType: .enfp,
        gender: .nonBinary,
        relationshipType: .friend,
        focusPoints: 980,
        streakDays: 8,
        dailyScreenTimeHours: 5.2,
        avgSessionLengthMinutes: 32,
        totalFocusHours: 65.2,
        rank: 2
    ),
    
    // Friend - Casual user
    Friend(
        id: UUID(),
        name: "Taylor Wilson",
        personalityType: .istp,
        gender: .female,
        relationshipType: .friend,
        focusPoints: 750,
        streakDays: 5,
        dailyScreenTimeHours: 4.1,
        avgSessionLengthMinutes: 28,
        totalFocusHours: 42.8,
        rank: 3
    ),
    
    // Acquaintance - New user
    Friend(
        id: UUID(),
        name: "Jordan Lee",
        personalityType: .infj,
        gender: .male,
        relationshipType: .acquaintance,
        focusPoints: 450,
        streakDays: 2,
        dailyScreenTimeHours: 6.8,
        avgSessionLengthMinutes: 21,
        totalFocusHours: 18.5,
        rank: 4
    ),
    
    // Friend - Long sessions, less frequent
    Friend(
        id: UUID(),
        name: "Casey Kim",
        personalityType: .estj,
        gender: .female,
        relationshipType: .friend,
        focusPoints: 680,
        streakDays: 3,
        dailyScreenTimeHours: 5.5,
        avgSessionLengthMinutes: 52,
        totalFocusHours: 64.2,
        rank: 5
    )
]
```

### Notes
- `PersonalityType` is an enum with all 16 MBTI types (e.g., .intj, .enfp, .istp, etc.)
- `Gender` is an enum with cases: .male, .female, .nonBinary
- `RelationshipType` is an enum with cases: .closeFriend, .friend, .acquaintance
- Focus points are awarded based on completed focus sessions and achievements
- Rank is determined by total focus points in descending order
