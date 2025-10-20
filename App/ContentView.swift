import SwiftUI

// MARK: - Custom Tab Infrastructure (inlined to ensure build target visibility)
struct TabItem {
    let icon: String
    let title: String
    let accent: Color
    let view: AnyView
    
    init<V: View>(icon: String, title: String, accent: Color, @ViewBuilder view: () -> V) {
        self.icon = icon
        self.title = title
        self.accent = accent
        self.view = AnyView(view())
    }
}

struct RetroTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                RetroTabButton(
                    icon: tab.icon,
                    title: tab.title,
                    accent: tab.accent,
                    isSelected: selectedTab == index,
                    action: { selectedTab = index }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.clear)
    }
}

struct RetroTabButton: View {
    let icon: String
    let title: String
    let accent: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .bold : .medium))
                    .foregroundColor(accent)
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(accent)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(minWidth: 60, minHeight: 56)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.defaultCream)
                .shadow(color: accent, radius: 0, x: 0, y: 4)
                .shadow(color: accent.opacity(0.2), radius: 12, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(accent, lineWidth: isSelected ? 2 : 1)
        )
        .opacity(isPressed ? 0.85 : 1.0)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct ContentView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @EnvironmentObject var focusManager: FocusManager
    @EnvironmentObject var appSettings: AppSettings
    
    @State private var selectedTab = 0
    
    private var tabs: [TabItem] {
        [
            TabItem(icon: "house.fill", title: "Nudge", accent: Color.greenPrimary) { NudgeHomeView() },
            TabItem(icon: "handshake.fill", title: "Stakes", accent: Color.orangePrimary) { ContractsView() },
            TabItem(icon: "person.text.rectangle", title: "My Type", accent: Color.cyanPrimary) { MyTypeView() },
            TabItem(icon: "person.3.fill", title: "Friends", accent: Color.bluePrimary) { LeaderboardView() },
            TabItem(icon: "person.fill", title: "Profile", accent: Color.tealPrimary) { ProfileView() }
        ]
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Global mint background for all tabs
            Color(red: 130/255, green: 237/255, blue: 166/255).ignoresSafeArea()
            
            // Main content area
            VStack(spacing: 0) {
                // Current tab content
                if selectedTab < tabs.count {
                    tabs[selectedTab].view
                        .foregroundColor(Color.green)
                        .background(Color(red: 130/255, green: 237/255, blue: 166/255).ignoresSafeArea())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Color.clear
                }
            }
            
            // Footer sits above custom tab bar
            VStack {
                Spacer()
                FooterFocusBarView(viewModel: FooterFocusBarViewModel())
                    .padding(.bottom, 120) // More space above custom tab bar
            }
            
            // Custom retro tab bar at bottom
            VStack {
                Spacer()
                RetroTabBar(selectedTab: $selectedTab, tabs: tabs)
                    .padding(.bottom, 34) // Safe area padding
            }
        }
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(appSettings.colorScheme)
        .onAppear {
            print("Tab layout loaded")
            print("Personality type: \(personalityManager.personalityType?.rawValue ?? "nil")")
        }
    }
    
    
    // MARK: - Tabs Content
    struct NudgeHomeView: View {
        @EnvironmentObject var personalityManager: PersonalityManager
        @EnvironmentObject var focusManager: FocusManager
        
        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    CharacterCard(title: "Alex", size: 280)
                    
                    Spacer(minLength: 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.bottom, 180) // Extra padding to avoid footer overlap
            }
        }
    }
    
    struct MyTypeView: View {
        @EnvironmentObject var personalityManager: PersonalityManager
        
        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    if let type = personalityManager.personalityType {
                        PersonalityBadge(personalityType: type, gender: personalityManager.gender)
                            .padding(.top, 12)
                        Text(type.displayName)
                            .font(.title2).bold()
                        Text(type.rawValue)
                            .font(.headline)
                    } else {
                        Text("Take the personality test to see your type")
                            .font(.headline)
                            .padding()
                    }
                    Spacer()
                }
                .padding()
                .padding(.bottom, 180) // Extra padding to avoid footer overlap
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PersonalityManager())
        .environmentObject(FocusManager())
        .environmentObject(AppSettings())
}
