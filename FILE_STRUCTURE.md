# File Structure

Generated on 2025-10-21

```
Folder PATH listing for volume Volume
Volume serial number is 00000009 D206:B0FC
A:.
│   APP_FLOW_GUIDE.md
│   BUILD_TROUBLESHOOTING_GUIDE.md
│   codemagic.yaml
│   COMPONENT_CREATION_RULES.md
│   DEBUG_ContentView.swift
│   HOME_PAGE_IMPLEMENTATION.md
│   Info.plist
│   IOS_COMPONENT_MIGRATION_STRATEGY.md
│   onbording plan.md
│   Phase1_Setup.md
│   QUICK_BUILD_GUIDE.md
│   README.md
│   TESTING_SETUP.md
│   WARP.md
│   XCODE_PROJECT_FIX.md
│   
├───App
│   │   ContentView.swift
│   │   Info.plist
│   │   NudgeApp.swift
│   │   
│   ├───Assets.xcassets
│   │   │   Contents.json
│   │   │   
│   │   ├───AccentColor.colorset
│   │   │       Contents.json
│   │   │       
│   │   ├───AppIcon.appiconset
│   │   │       Contents.json
│   │   │       
│   │   ├───ENFJM.imageset
│   │   │       Contents.json
│   │   │       ENFJM.png
│   │   │       
│   │   ├───ENFJW.imageset
│   │   │       Contents.json
│   │   │       ENFJW.png
│   │   │       
│   │   ├───ENFPM.imageset
│   │   │       Contents.json
│   │   │       ENFPM.png
│   │   │       
│   │   ├───ENFPW.imageset
│   │   │       Contents.json
│   │   │       ENFPW.png
│   │   │       
│   │   ├───ENTJM.imageset
│   │   │       Contents.json
│   │   │       ENTJM.png
│   │   │       
│   │   ├───ENTJW.imageset
│   │   │       Contents.json
│   │   │       ENTJW.png
│   │   │       
│   │   ├───ENTPM.imageset
│   │   │       Contents.json
│   │   │       ENTPM.png
│   │   │       
│   │   ├───ENTPW.imageset
│   │   │       Contents.json
│   │   │       ENTPW.png
│   │   │       
│   │   ├───ESFJM.imageset
│   │   │       Contents.json
│   │   │       ESFJM.png
│   │   │       
│   │   ├───ESFJW.imageset
│   │   │       Contents.json
│   │   │       ESFJW.png
│   │   │       
│   │   ├───ESFPM.imageset
│   │   │       Contents.json
│   │   │       ESFPM.png
│   │   │       
│   │   ├───ESFPW.imageset
│   │   │       Contents.json
│   │   │       ESFPW.png
│   │   │       
│   │   ├───ESTJM.imageset
│   │   │       Contents.json
│   │   │       ESTJM.png
│   │   │       
│   │   ├───ESTJW.imageset
│   │   │       Contents.json
│   │   │       ESTJW.png
│   │   │       
│   │   ├───ESTPM.imageset
│   │   │       Contents.json
│   │   │       ESTPM.png
│   │   │       
│   │   ├───ESTPW.imageset
│   │   │       Contents.json
│   │   │       ESTPW.png
│   │   │       
│   │   ├───INFJM.imageset
│   │   │       Contents.json
│   │   │       INFJM.png
│   │   │       
│   │   ├───INFJW.imageset
│   │   │       Contents.json
│   │   │       INFJW.png
│   │   │       
│   │   ├───INFPM.imageset
│   │   │       Contents.json
│   │   │       INFPM.png
│   │   │       
│   │   ├───INFPW.imageset
│   │   │       Contents.json
│   │   │       INFPW.png
│   │   │       
│   │   ├───INTJM.imageset
│   │   │       Contents.json
│   │   │       INTJM.png
│   │   │       
│   │   ├───INTJW.imageset
│   │   │       Contents.json
│   │   │       INTJW.png
│   │   │       
│   │   ├───INTPM.imageset
│   │   │       Contents.json
│   │   │       INTPM.png
│   │   │       
│   │   ├───INTPW.imageset
│   │   │       Contents.json
│   │   │       INTPW.png
│   │   │       
│   │   ├───ISFJM.imageset
│   │   │       Contents.json
│   │   │       ISFJM.png
│   │   │       
│   │   ├───ISFJW.imageset
│   │   │       Contents.json
│   │   │       ISFJW.png
│   │   │       
│   │   ├───ISFPM.imageset
│   │   │       Contents.json
│   │   │       ISFPM.png
│   │   │       
│   │   ├───ISFPW.imageset
│   │   │       Contents.json
│   │   │       ISFPW.png
│   │   │       
│   │   ├───ISTJM.imageset
│   │   │       Contents.json
│   │   │       ISTJM.png
│   │   │       
│   │   ├───ISTJW.imageset
│   │   │       Contents.json
│   │   │       ISTJW.png
│   │   │       
│   │   ├───ISTPM.imageset
│   │   │       Contents.json
│   │   │       ISTPM.png
│   │   │       
│   │   └───ISTPW.imageset
│   │           Contents.json
│   │           ISTPW.png
│   │           
│   └───Preview Content
│       └───Preview Assets.xcassets
│               Contents.json
│               
├───Core
│   │   PersistenceController.swift
│   │   
│   ├───Feedback
│   │       HapticsService.swift
│   │       
│   └───Services
│           AppIconCatalog.swift
│           AppSettings.swift
│           FocusManager.swift
│           FooterFocusBarViewModel.swift
│           PersonalityManager.swift
│           PrivateAppIconProvider.swift
│           RestrictionsController.swift
│           
├───Features
│   │   PlaceholderViews.swift
│   │   
│   ├───Contracts
│   │       ContractsView.swift
│   │       
│   ├───Dashboard
│   │       DashboardView.swift
│   │       
│   ├───Focus
│   │       FocusSettingsView.swift
│   │       
│   ├───Leaderboard
│   │       LeaderboardView.swift
│   │       
│   ├───Onboarding
│   │   │   OnboardingFlowView.swift
│   │   │   OnboardingView.swift
│   │   │   
│   │   ├───Choice
│   │   │       OnboardingChoiceView.swift
│   │   │       
│   │   ├───Components
│   │   │       ProgressBar.swift
│   │   │       TypewriterText.swift
│   │   │       
│   │   ├───Greeting
│   │   │       GreetingView.swift
│   │   │       
│   │   └───NameEntry
│   │           NameEntryView.swift
│   │           
│   └───Profile
│           ProfileView.swift
│           
├───Nudge.xcodeproj
│       project.pbxproj
│       project.pbxproj.backup
│       project.pbxproj.old
│       
├───NudgeMinimal
│   │   ContentView.swift
│   │   NudgeApp.swift
│   │   
│   └───Assets.xcassets
├───Resources
│   ├───Fonts
│   │       Nippo-Regular.otf
│   │       Tanker-Regular.otf
│   │       
│   ├───Images
│   │       ENFJM.png
│   │       ENFJW.439Z.png
│   │       ENFPM.357Z.png
│   │       ENFPW.964Z.png
│   │       ENTJM.jpeg
│   │       ENTJW.jpeg
│   │       ENTPM.364Z.png
│   │       ENTPW.982Z.png
│   │       ESFJM.978Z.png
│   │       ESFJW.059Z.png
│   │       ESFPM.png
│   │       ESFPW.png
│   │       ESTJM.161Z.png
│   │       ESTJW.png
│   │       ESTPM.258Z.png
│   │       ESTPW.031Z.png
│   │       INFJM.984Z.png
│   │       INFJW.285Z.png
│   │       INFPM.716Z.png
│   │       INFPW.504Z.png
│   │       instagram.png
│   │       INTJM.475Z.png
│   │       INTJW.png
│   │       INTPM.896Z.png
│   │       INTPW.512Z.png
│   │       ISFJM.077Z.png
│   │       ISFJW.211Z.png
│   │       ISFPM.696Z.png
│   │       ISFPW.131Z.png
│   │       ISTJM.502Z.png
│   │       ISTJW.png
│   │       ISTPM.560Z.png
│   │       ISTPW.png
│   │       Nudge logo.png
│   │       nudge2.png
│   │       
│   └───Videos
│           ENFJM.mp4
│           ENFJW.439Z.mp4
│           ENFPM.357Z.mp4
│           ENFPW.964Z.mp4
│           ENTJM.mp4
│           ENTJW.mp4
│           ENTPM.364Z.mp4
│           ENTPW.982Z.mp4
│           ESFJM.978Z.mp4
│           ESFJW.059Z.mp4
│           ESFPM.mp4
│           ESFPW.mp4
│           ESTJM.mp4
│           ESTJW.mp4
│           ESTPM.258Z.mp4
│           ESTPW.031Z.mp4
│           INFJM.984Z.mp4
│           INFJW.285Z.mp4
│           INFPM.mp4
│           INFPW.504Z.mp4
│           INTJM.mp4
│           INTJW.mp4
│           INTPM.896Z.mp4
│           INTPW.512Z.mp4
│           ISFJM.077Z.mp4
│           ISFJW.211Z.mp4
│           ISFPM.696Z.mp4
│           ISFPW.131Z.mp4
│           ISTJM.502Z.mp4
│           ISTJW.mp4
│           ISTPM.560Z.mp4
│           ISTPW.mp4
│           
└───UI
    ├───Components
    │       CharacterCard.swift
    │       FocusRing.swift
    │       FooterFocusBarView.swift
    │       NudgeNavBarView.swift
    │       PersonalityBadge.swift
    │       
    └───Theme
            Colors.swift
            NudgeStyles.swift
            PersonalityTheme.swift
            ```

