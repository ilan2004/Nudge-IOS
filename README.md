# Nudge iOS - SwiftUI App

A native iOS implementation of the Nudge productivity app, featuring personality-driven theming and focus management.

## 🎯 **Current Development Strategy**

We are **systematically recreating all web components from React/Next.js into native SwiftUI**, ensuring feature parity while leveraging iOS-specific capabilities.

📋 **[📖 COMPONENT MIGRATION STRATEGY →](./IOS_COMPONENT_MIGRATION_STRATEGY.md)**

This document contains our complete roadmap for translating web components to iOS, including:
- Component-by-component migration map
- React → SwiftUI translation examples
- Implementation guidelines and best practices
- Progress tracking and priorities

## 📚 **Documentation Index**

### **Development Guides**
- **[IOS_COMPONENT_MIGRATION_STRATEGY.md](./IOS_COMPONENT_MIGRATION_STRATEGY.md)** - Main strategy document
- **[Phase1_Setup.md](./Phase1_Setup.md)** - Foundation setup (completed)
- **[QUICK_BUILD_GUIDE.md](./QUICK_BUILD_GUIDE.md)** - How to build and run
- **[BUILD_TROUBLESHOOTING_GUIDE.md](./BUILD_TROUBLESHOOTING_GUIDE.md)** - Common issues

### **Feature Guides**
- **[APP_FLOW_GUIDE.md](./APP_FLOW_GUIDE.md)** - User experience flows
- **[HOME_PAGE_IMPLEMENTATION.md](./HOME_PAGE_IMPLEMENTATION.md)** - Dashboard design
- **[TESTING_SETUP.md](./TESTING_SETUP.md)** - Testing framework

### **Technical References**
- **[XCODE_PROJECT_FIX.md](./XCODE_PROJECT_FIX.md)** - Project configuration
- **[codemagic.yaml](./codemagic.yaml)** - CI/CD configuration

## 🚀 **Quick Start**

### **Open in Xcode**
```bash
cd ios/
open Nudge.xcodeproj
# Press Cmd+R to build and run
```

### **Current Status** (Phase 1 ✅)
- ✅ Complete SwiftUI app architecture
- ✅ Tab-based navigation (5 main screens)
- ✅ Personality-driven theming system
- ✅ 64 MBTI assets (32 images + 32 videos)
- ✅ Focus timer with notifications
- ✅ Core managers and services

## 🗂️ **Project Structure**

```
ios/
├── App/                    # App entry point & main views
│   ├── NudgeApp.swift     # Main app struct
│   ├── ContentView.swift  # Root view with tabs
│   └── DEBUG_ContentView.swift  # Debug version
│
├── Core/                   # Business logic & services
│   ├── Models/            # Data models & types
│   ├── Services/          # Managers (Personality, Focus, etc.)
│   └── PersistenceController.swift  # Core Data stack
│
├── Features/              # Feature modules (screens)
│   ├── Dashboard/         # Main dashboard ✅
│   ├── Focus/            # Focus timer (placeholder)
│   ├── Leaderboard/      # Social features (placeholder)
│   ├── Contracts/        # Accountability (placeholder)
│   ├── Profile/          # User settings (placeholder)
│   └── PlaceholderViews.swift  # Temporary views
│
├── UI/                    # Reusable components & theming
│   ├── Components/        # CharacterCard, PersonalityBadge, etc.
│   ├── Theme/            # PersonalityTheme, Colors
│   └── Extensions/        # SwiftUI extensions
│
├── Resources/             # Assets, fonts, videos
│   ├── Assets.xcassets/   # App icons, images
│   ├── Fonts/            # Tanker font family
│   ├── Images/           # 32 personality images
│   └── Videos/           # 32 personality videos
│
└── Nudge.xcodeproj/      # Xcode project file
```

## 🛠️ **Technology Stack**

- **Framework**: SwiftUI + UIKit hybrid
- **Architecture**: MVVM with ObservableObject
- **Data Persistence**: UserDefaults + Core Data (planned)
- **Networking**: URLSession (Supabase integration planned)
- **Blocking**: Screen Time API (planned)
- **Notifications**: UserNotifications framework
- **Testing**: XCTest framework

## 🎨 **Design System**

### **Personality-Driven Theming**
- **16 MBTI Types**: Each with unique color palette
- **2 Gender Variants**: Male/Female character representations
- **Dynamic Themes**: UI adapts to user's personality type
- **Consistent Branding**: Matches web app design

### **Typography**
- **Display**: Tanker font family (custom)
- **Body**: SF Pro (system default)
- **Accessibility**: Dynamic Type support

### **Components**
- Native SwiftUI controls and navigation
- Custom personality-themed components
- Smooth animations and haptic feedback

## 📱 **Component Migration Progress**

### **✅ Completed Components**
- `CharacterCard.swift` - Personality avatar display
- `PersonalityBadge.swift` - MBTI type indicator  
- `FocusRing.swift` - Timer visualization
- `DashboardView.swift` - Main screen layout
- `PersonalityManager.swift` - MBTI management
- `FocusManager.swift` - Timer functionality
- `PersonalityTheme.swift` - Dynamic theming

### **🔄 In Progress**
- `ProfileView.swift` - User settings screen
- Focus blocking system integration
- Personality test UI implementation

### **📋 Planned**
- Social features (leaderboard, contracts)
- Backend integration (Supabase)
- Advanced iOS features (widgets, shortcuts)

## 🧪 **Development Workflow**

### **For Each Web Component:**

1. **📋 Analysis**
   - Study the React component in `web/src/components/`
   - Map props, state, and interactions
   - Identify dependencies and APIs

2. **🎨 Design**
   - Create SwiftUI view structure
   - Plan state management (@State, @EnvironmentObject)
   - Consider iOS-specific enhancements

3. **⚡ Implementation**
   - Build basic UI structure
   - Add business logic and ViewModels
   - Test on device/simulator

4. **🚀 Enhancement**
   - Add haptic feedback and animations
   - Implement accessibility features
   - Optimize performance

## 🎯 **Next Development Priorities**

1. **Focus Blocking System** - Screen Time API integration
2. **Personality Test UI** - Interactive MBTI assessment
3. **Backend Connection** - Supabase API integration  
4. **Social Features** - Leaderboard and contracts
5. **Advanced iOS Features** - Widgets, Siri Shortcuts

## 🤝 **Contributing**

When working on iOS components:

1. **Follow the [Migration Strategy](./IOS_COMPONENT_MIGRATION_STRATEGY.md)**
2. **Reference the original React component** in `web/src/components/`
3. **Use SwiftUI best practices** and native patterns
4. **Test on multiple devices** and orientations
5. **Update documentation** as you build

## 📄 **License**

This project is part of the Nudge productivity suite. All rights reserved.

---

**Ready to build? Open `Nudge.xcodeproj` in Xcode and start developing! 🚀**
