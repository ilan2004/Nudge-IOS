// UI/Components/RetroTabView.swift
import SwiftUI

struct RetroTabView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        setupTabBarAppearance()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content
            
            // Custom tab bar background overlay
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    // This creates the retro console surface effect
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 49) // Standard tab bar height
                        .padding(.horizontal, 16)
                        .retroConsoleSurface()
                        .padding(.bottom, 34) // Safe area bottom padding
                    Spacer()
                }
            }
            .allowsHitTesting(false) // Let tab bar touches pass through
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
        // Tab item styling
        let borderColor = UIColor(Color("NudgeGreen900", bundle: .main, default: Color(red: 0.01, green: 0.35, blue: 0.30)))
        let normalColor = borderColor.withAlphaComponent(0.6)
        let selectedColor = borderColor
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]
        
        // Apply to all tab bars
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    RetroTabView {
        TabView {
            Text("Tab 1")
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            Text("Tab 2")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
    .background(Color(red: 130/255, green: 237/255, blue: 166/255))
}
