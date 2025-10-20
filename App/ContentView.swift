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
        HStack(spacing: 8) {
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
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.988, green: 0.973, blue: 0.949)) // defaultCream
                .shadow(color: Color(red: 0.01, green: 0.35, blue: 0.30), radius: 0, x: 0, y: -4) // upward drop shadow
                .shadow(color: Color(red: 0.01, green: 0.35, blue: 0.30).opacity(0.2), radius: 12, x: 0, y: -8) // upward soft shadow
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(red: 0.01, green: 0.35, blue: 0.30), lineWidth: 2)
        )
        .padding(.horizontal, 16)
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
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minWidth: 70, minHeight: 66)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.988, green: 0.973, blue: 0.949)) // defaultCream hardcoded
                .shadow(color: accent, radius: 0, x: 0, y: 4)
                .shadow(color: accent.opacity(0.2), radius: 12, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(accent, lineWidth: isSelected ? 3 : 2)
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
    
    // Accent colors - hardcoded for visibility
    private var accentGreen: Color { Color(red: 0.01, green: 0.35, blue: 0.30) } // Dark green
    private var accentOrange: Color { Color(red: 0.85, green: 0.46, blue: 0.02) } // Orange
    private var accentCyan: Color { Color(red: 0.03, green: 0.57, blue: 0.70) } // Cyan
    private var accentBlue: Color { Color(red: 0.392, green: 0.584, blue: 0.929) } // Blue
    private var accentTeal: Color { Color(red: 0.439, green: 0.859, blue: 0.804) } // Teal
    
    private var tabs: [TabItem] {
        [
            TabItem(icon: "house.fill", title: "Nudge", accent: accentGreen) { NudgeHomeView() },
            TabItem(icon: "handshake.fill", title: "Stakes", accent: accentOrange) { ContractsView() },
            TabItem(icon: "person.text.rectangle", title: "My Type", accent: accentCyan) { MyTypeView() },
            TabItem(icon: "person.3.fill", title: "Friends", accent: accentBlue) { LeaderboardView() },
            TabItem(icon: "person.fill", title: "Profile", accent: accentTeal) { ProfileView() }
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
                    .padding(.bottom, 8) // Closer to bottom like native tab bars
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
