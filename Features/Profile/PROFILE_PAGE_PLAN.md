# Profile Page — UI Plan and Implementation Notes

Sections (top→bottom)
- Identity header
  - CharacterCard (~240), user name with “Edit”, PersonalityBadge.
  - Empty state: CharacterPlaceholder + CTA “Take MBTI Test”.
- Focus economy
  - FocusEconomyCard showing: Total Focus Points (primary metric) and Focus Coins.
  - Action: “History” (optional modal/route);
- Core stats
  - 2×2 grid cards: Total Focus Hours, Weekly Trend (mini bars), Streak, Distractions Blocked.
- Achievements
  - Horizontal strip of badges (locked/unlocked) with subtle pop on unlock.
- Social snapshot
  - Leaderboard tile: current rank and weekly delta; “See Full Leaderboard”.
  - Dims when Underground Mode is ON.
- Underground Mode
  - Toggle card with short copy; controls visibility to others but keeps personal stats visible.
- Smart Blocking
  - “Blocked Apps” row with top 3 icons + “Manage”.
- Settings
  - List of SettingsRow items: Retake MBTI, Notifications, Data & Privacy, About.

Visual style
- Use retroConsoleSurface() for cards; Tanker-Regular for headings; accents via PersonalityTheme.colors.
- Use NavPillStyle for CTAs. Subtle animations on milestone changes.

Data dependencies
- PersonalityManager: personalityType, gender, currentTheme.
- FocusManager: totalFocusTime, currentStreak, sessionsCompleted.
- EconomyService (new): totalFocusPoints, totalFocusCoins.
- AppSettings: undergroundMode (added).
- RestrictionsController: optional for blocked apps data (placeholder for now).

Implementation steps
1) Add EconomyService with persisted totals (UserDefaults keys: nudge_total_fp, nudge_total_fc).
2) Extend AppSettings with undergroundMode (UserDefaults persisted).
3) Implement UI components (as SwiftUI subviews inside ProfileView for speed):
   - FocusEconomyCard, StatsGrid, AchievementStrip, LeaderboardTile, UndergroundToggleCard, BlockedAppsRow, SettingsList.
4) Update ProfileView to compose sections; wire to EnvironmentObjects.
5) Hook previews with stub EconomyService/AppSettings.

