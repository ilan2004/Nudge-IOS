# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Build Commands

### Open and Build in Xcode
```bash
open Nudge.xcodeproj
# Press ⌘+R to build and run
```

### Build for Simulator (Command Line)
```bash
xcodebuild -project Nudge.xcodeproj -scheme Nudge -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Archive for Distribution
```bash
xcodebuild archive -project Nudge.xcodeproj -scheme Nudge -configuration Release -destination "generic/platform=iOS" -archivePath build/Nudge.xcarchive
```

### CI/CD Build (CodeMagic)
- Automated builds configured via `codemagic.yaml`
- Creates unsigned IPA for testing
- Email notifications on build completion/failure

### Clean Build
```bash
# In Xcode: ⌘+Shift+K
# Or command line:
xcodebuild clean -project Nudge.xcodeproj -scheme Nudge
```

## Architecture Overview

### High-Level Architecture
This is a **SwiftUI-based iOS app** using **MVVM architecture** that recreates React/Next.js web components in native iOS. The app features personality-driven theming based on MBTI types and a focus timer system.

### Core Design Patterns
- **MVVM with ObservableObject**: ViewModels manage business logic (`PersonalityManager`, `FocusManager`)  
- **Environment Objects**: Dependency injection for shared state across views
- **Reactive Updates**: `@Published` properties automatically trigger UI updates
- **Component-Based Architecture**: Reusable SwiftUI components mirror web counterparts

### Project Structure
```
App/                 # Entry point and main views
├── NudgeApp.swift   # Main app struct with dependency setup
├── ContentView.swift        # Root tab navigation
└── DEBUG_ContentView.swift  # Debug/testing interface

Core/                # Business logic and services  
├── Services/        # Manager classes (ObservableObject)
│   ├── PersonalityManager.swift  # MBTI personality state
│   ├── FocusManager.swift        # Timer and session management
│   ├── AppSettings.swift         # User preferences
│   └── RestrictionsController.swift # Focus blocking (planned)
└── PersistenceController.swift   # Core Data stack

UI/                  # Reusable components and theming
├── Components/      # SwiftUI components
│   ├── CharacterCard.swift       # Main hero component with MBTI avatar
│   ├── PersonalityBadge.swift    # MBTI type indicator
│   ├── FocusRing.swift          # Timer progress visualization
│   └── FooterFocusBarView.swift # Bottom focus controls
└── Theme/          # Theming system
    ├── PersonalityTheme.swift    # MBTI-based color palettes (16 types)
    └── Colors.swift             # Base color definitions

Features/           # Screen modules
├── Dashboard/      # Main dashboard (✅ Complete)
├── Onboarding/     # User setup flow
└── Focus/          # Focus timer settings
```

### Key Architectural Components

#### PersonalityManager
**Central state manager for MBTI personality system:**
- Manages 16 MBTI personality types with gender variants
- Handles personality test scoring and results
- Provides dynamic theming based on personality type
- Persists user personality data to UserDefaults
- Loads corresponding character images/videos (64 total assets)

#### FocusManager  
**Timer and productivity session management:**
- Implements Pomodoro-style focus sessions (25min focus, 5min break)
- Tracks session progress, streaks, and total focus time
- Manages focus states: idle, focusing, onBreak, paused
- Schedules local notifications for session completion
- Persists focus statistics and streak data

#### PersonalityTheme
**Dynamic theming system with 16 MBTI color palettes:**
- Each personality type has unique primary, secondary, accent colors
- Supports male/female character variants (M/W suffixes)
- Provides helper methods for loading personality-specific media assets
- Maintains consistent color scheme across all UI components

#### CharacterCard
**Main hero component displaying user's personality avatar:**
- Shows personality-specific character images and animations
- Integrates FocusRing for session progress visualization  
- Displays personality-specific dialogue and motivational messages
- Supports video animations for character interactions
- Handles media loading from bundle (Images/ and Videos/ folders)

### Component Migration Strategy
This app systematically recreates React/Next.js web components in SwiftUI:

**Completed Migrations:**
- `CharacterCard.jsx` → `CharacterCard.swift` (Hero personality display)
- `PersonalityBadge.jsx` → `PersonalityBadge.swift` (MBTI type indicator)  
- `FocusRing.jsx` → `FocusRing.swift` (Timer visualization)
- `DashboardView` → Native SwiftUI dashboard with focus stats

**Translation Pattern:**
1. **Analyze** React component props, state, and interactions
2. **Design** SwiftUI equivalent with @State/@Binding/@EnvironmentObject
3. **Implement** using native iOS patterns and SwiftUI idioms
4. **Enhance** with iOS-specific features (haptics, notifications, accessibility)

### Data Flow
1. **App Launch**: `NudgeApp.swift` initializes managers as `@StateObject`
2. **Dependency Injection**: Managers injected as `@EnvironmentObject` throughout view hierarchy
3. **State Updates**: `@Published` properties in managers trigger automatic UI updates
4. **Persistence**: Critical data saved to UserDefaults (personality, settings, stats)
5. **Asset Loading**: Dynamic loading of 64 personality assets (32 images + 32 videos)

### Asset System
**Personality-Driven Asset Loading:**
- **32 Character Images**: `{MBTI}M.png` and `{MBTI}W.png` (e.g., `ENFJM.png`, `ENFJW.png`)
- **32 Character Videos**: `{MBTI}M.mp4` and `{MBTI}W.mp4` for animations
- **Dynamic Loading**: `PersonalityTheme.mediaName()` generates correct filenames
- **Fallback Handling**: Graceful degradation when assets missing

## Development Workflow

### Component Development Process
When adding new SwiftUI components that mirror web components:

1. **Reference Original**: Study the React component in web codebase
2. **Plan Architecture**: Decide on @State, @Binding, @EnvironmentObject usage  
3. **Implement Core**: Build basic UI structure and business logic
4. **Add Interactions**: Implement user interactions and animations
5. **Test Multi-Device**: Verify on iPhone/iPad, different orientations
6. **iOS Enhancement**: Add haptics, accessibility, native iOS features

### Testing Approach
- **Manual Testing**: Use iPhone Simulator with different device types
- **Debug Views**: `DEBUG_ContentView.swift` for isolated component testing
- **Asset Testing**: Verify all 64 personality assets load correctly
- **Theme Testing**: Test all 16 MBTI personality themes and color palettes

### Key Development Files
- **`QUICK_BUILD_GUIDE.md`**: Step-by-step build instructions
- **`IOS_COMPONENT_MIGRATION_STRATEGY.md`**: Detailed React→SwiftUI migration plan
- **`BUILD_TROUBLESHOOTING_GUIDE.md`**: Common build issues and solutions
- **`codemagic.yaml`**: CI/CD configuration for automated builds

## Important Implementation Details

### MBTI Personality System
- **16 Types**: All Myers-Briggs personality types supported (INTJ, ENFP, etc.)
- **Gender Variants**: Male/Female character representations for each type  
- **Test Scoring**: Built-in personality assessment with dimension scoring
- **Dynamic Theming**: UI colors adapt based on user's personality type
- **Asset Naming**: Consistent `{TYPE}{GENDER}` pattern (e.g., `ENFJW`, `INTJM`)

### Focus Timer Integration
- **Pomodoro Technique**: 25-minute focus sessions with 5-minute breaks
- **Visual Feedback**: FocusRing component shows session progress
- **Notifications**: Local notifications for session completion
- **Streak Tracking**: Daily focus streak calculation and persistence
- **Statistics**: Total focus time, sessions completed, current streak

### SwiftUI Architecture Patterns
- **ObservableObject Managers**: Centralized state management for personality and focus
- **Environment Injection**: Shared managers accessible throughout view hierarchy
- **Reactive UI Updates**: `@Published` properties automatically update UI
- **Component Composition**: Reusable components following single responsibility principle

### Asset and Resource Management
- **Bundle Assets**: All personality images/videos in main app bundle
- **Dynamic Loading**: Runtime asset loading based on personality type and gender
- **Fallback Strategy**: Graceful handling of missing assets with placeholder views
- **Custom Fonts**: Tanker font family for brand consistency with web app
