# iOS Component Migration Strategy
## Recreating Web Components in SwiftUI

### 🎯 **Project Goal**
We are systematically recreating all React/Next.js web components from the `web/` directory into native SwiftUI components in the `ios/` directory. This ensures feature parity between platforms while leveraging native iOS capabilities.

---

## 📋 **Migration Methodology**

### **Phase-by-Phase Approach**
1. **Analyze** the React component structure and functionality
2. **Design** the SwiftUI equivalent architecture  
3. **Implement** with native iOS patterns (MVVM, ObservableObject)
4. **Enhance** with iOS-specific features (haptics, notifications, etc.)
5. **Test** on device/simulator for performance and UX

### **Design Principles**
- ✅ **Native Feel**: Use SwiftUI idioms, not direct React translations
- ✅ **Performance**: Leverage SwiftUI's declarative nature
- ✅ **Accessibility**: Built-in VoiceOver and accessibility support
- ✅ **Platform Features**: Screen Time API, Focus Filters, Siri Shortcuts

---

## 🗂️ **Component Migration Map**

### **Core UI Components** (`web/src/components/` → `ios/UI/Components/`)

| Web Component | iOS Equivalent | Status | Priority | Notes |
|---------------|----------------|---------|----------|-------|
| `CharacterCard.jsx` | `CharacterCard.swift` | ✅ Done | High | Personality avatar display |
| `PersonalityBadge.jsx` | `PersonalityBadge.swift` | ✅ Done | High | MBTI type indicator |
| `FocusRing.jsx` | `FocusRing.swift` | ✅ Done | High | Timer visualization |
| `NotificationSnackbar.jsx` | `NotificationBanner.swift` | 📋 Planned | Medium | Native iOS alerts |
| `ProductivityGraph.jsx` | `ProductivityChart.swift` | 📋 Planned | Medium | Charts framework |
| `LeaderboardSection.jsx` | `LeaderboardCard.swift` | 📋 Planned | Medium | Social rankings |
| `ContractTracker.jsx` | `ContractView.swift` | 📋 Planned | Medium | Accountability system |
| `ThemeDebug.jsx` | `ThemeDebugView.swift` | 📋 Planned | Low | Development tool |

### **Feature Pages** (`web/src/app/` → `ios/Features/`)

| Web Page | iOS Feature | Status | Priority | Notes |
|----------|-------------|---------|----------|-------|
| `dashboard/page.js` | `Dashboard/DashboardView.swift` | ✅ Done | High | Main screen |
| `profile/page.js` | `Profile/ProfileView.swift` | 🔄 In Progress | High | User settings |
| `about/[type]/page.js` | `About/PersonalityDetailView.swift` | 📋 Planned | Medium | MBTI info |
| `leaderboard/page.js` | `Leaderboard/LeaderboardView.swift` | 📋 Planned | Medium | Social features |
| `stake/page.js` | `Contracts/ContractsView.swift` | 📋 Planned | Medium | Commitments |
| `mobile-setup/page.jsx` | `Settings/MobileSetupView.swift` | 📋 Planned | Low | DNS blocking |

### **Business Logic** (`web/src/` → `ios/Core/`)

| Web Module | iOS Service | Status | Priority | Notes |
|------------|-------------|---------|----------|-------|
| `lib/mbtiLocalScoring.js` | `Services/MBTIScoring.swift` | ✅ Done | High | Personality algorithm |
| `contexts/ThemeContext.jsx` | `Services/ThemeManager.swift` | ✅ Done | High | Color theming |
| `hooks/usePersonalizationProfile.js` | `Services/PersonalityManager.swift` | ✅ Done | High | User profile |
| `lib/supabase.js` | `Network/SupabaseClient.swift` | 📋 Planned | Medium | Backend integration |
| `lib/blocklist.js` | `Services/BlockingService.swift` | 📋 Planned | High | Focus blocking |

---

## 🛠️ **Implementation Guidelines**

### **SwiftUI Best Practices**
```swift
// ✅ DO: Use ObservableObject for state management
class PersonalityManager: ObservableObject {
    @Published var personalityType: PersonalityType?
    @Published var currentTheme: PersonalityColors
}

// ✅ DO: Follow SwiftUI naming conventions
struct CharacterCard: View {
    let personalityType: PersonalityType
    let size: CGFloat
}

// ✅ DO: Use native iOS patterns
.onAppear { loadData() }
.swipeActions { deleteAction() }
.contextMenu { shareAction() }
```

### **Architecture Patterns**
- **MVVM**: ViewModels manage business logic
- **Dependency Injection**: Services injected via `@EnvironmentObject`
- **Reactive Updates**: `@Published` properties trigger UI updates
- **Error Handling**: Native Swift Result types

### **iOS-Specific Enhancements**
```swift
// Native iOS features to add
.hapticFeedback(.impact(.light))  // Haptic feedback
.focusable()                      // Focus management
.accessibility(label: "Timer")    // VoiceOver support
.onBackground { saveState() }     // App lifecycle
```

---

## 📱 **Component Implementation Examples**

### **React → SwiftUI Translation**

**React Component:**
```jsx
const CharacterCard = ({ personalityType, size, title }) => {
  const theme = usePersonalityTheme(personalityType);
  
  return (
    <div className="character-card" style={{ backgroundColor: theme.surface }}>
      <img src={`/images/${personalityType}M.png`} />
      <h2 style={{ color: theme.primary }}>{title}</h2>
    </div>
  );
};
```

**SwiftUI Equivalent:**
```swift
struct CharacterCard: View {
    let personalityType: PersonalityType
    let size: CGFloat
    let title: String?
    
    @EnvironmentObject var personalityManager: PersonalityManager
    
    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: personalityManager.getPersonalityImageURL()) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            
            if let title = title {
                Text(title)
                    .font(.custom("Tanker-Regular", size: 24))
                    .foregroundColor(personalityManager.currentTheme.primary)
            }
        }
        .padding()
        .background(personalityManager.currentTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

---

## 🚀 **Development Workflow**

### **1. Component Analysis Phase**
- [ ] Study the React component's props, state, and lifecycle
- [ ] Identify external dependencies (hooks, contexts, APIs)
- [ ] Map user interactions and animations
- [ ] Note responsive design patterns

### **2. SwiftUI Design Phase**
- [ ] Create SwiftUI view structure
- [ ] Define `@State`, `@Binding`, and `@EnvironmentObject` properties
- [ ] Plan animation and interaction patterns
- [ ] Consider iPad/iPhone size classes

### **3. Implementation Phase**
- [ ] Create basic UI structure
- [ ] Implement business logic in ViewModel if needed
- [ ] Add animations and interactions
- [ ] Test on multiple devices/orientations

### **4. Enhancement Phase**
- [ ] Add iOS-specific features (haptics, focus, accessibility)
- [ ] Optimize performance
- [ ] Add unit tests
- [ ] Update documentation

---

## 📊 **Progress Tracking**

### **Current Status** (Phase 1 Complete)
- ✅ **Foundation**: App structure, navigation, theming
- ✅ **Core Components**: CharacterCard, PersonalityBadge, FocusRing
- ✅ **Services**: PersonalityManager, FocusManager, AppSettings
- ✅ **Assets**: All 64 personality images/videos migrated

### **Next Priorities**
1. **Focus Timer System** - Complete blocking functionality
2. **Personality Test UI** - Interactive MBTI assessment  
3. **Social Features** - Leaderboard and contracts
4. **Backend Integration** - Supabase connection
5. **Advanced Features** - Widgets, Siri Shortcuts

---

## 🎨 **Design System Consistency**

### **Shared Elements**
- **Colors**: Personality-based themes match web exactly
- **Typography**: Tanker font family for headings
- **Spacing**: 4px grid system (4, 8, 12, 16, 20, 24)
- **Corner Radius**: 8px (small), 12px (medium), 16px (large)

### **iOS Adaptations**
- **Navigation**: Native tab bar and navigation stack
- **Forms**: Native form controls and input fields  
- **Lists**: SwiftUI List with native swipe actions
- **Modals**: Sheet presentation with native gestures

---

## 🔄 **Continuous Integration**

### **Quality Checks**
- [ ] Code review for SwiftUI best practices
- [ ] Performance testing on older devices
- [ ] Accessibility audit with VoiceOver
- [ ] UI consistency check across orientations

### **Testing Strategy**
- **Unit Tests**: Business logic and data models
- **UI Tests**: Critical user flows and interactions
- **Manual Testing**: Real device testing for feel and performance
- **Beta Testing**: TestFlight for user feedback

---

## 📚 **Resources & References**

### **Documentation**
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Screen Time API](https://developer.apple.com/documentation/screentimeapi/)

### **Internal Resources**
- `web/src/components/` - Original React components
- `ios/UI/Theme/PersonalityTheme.swift` - Theme definitions
- `ios/Core/Models/` - Data models and types

---

**This migration strategy ensures we maintain feature parity while creating a truly native iOS experience that leverages platform-specific capabilities and follows Apple's design principles.**
