// UI/Components/RetroTabBar.swift
import SwiftUI

struct RetroTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                RetroTabButton(
                    icon: tab.icon,
                    title: tab.title,
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
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(.greenPrimary)
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(.greenPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(minWidth: 60, minHeight: 56)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96)))
                .shadow(color: .greenPrimary, radius: 0, x: 0, y: 4)
                .shadow(color: Color.greenPrimary.opacity(0.2), radius: 12, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.greenPrimary, lineWidth: isSelected ? 2 : 1)
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

struct TabItem {
    let icon: String
    let title: String
    let view: AnyView
    
    init<V: View>(icon: String, title: String, @ViewBuilder view: () -> V) {
        self.icon = icon
        self.title = title
        self.view = AnyView(view())
    }
}

#Preview {
    VStack {
        Spacer()
        
        RetroTabBar(
            selectedTab: .constant(0),
            tabs: [
                TabItem(icon: "house.fill", title: "Home") { Text("Home") },
                TabItem(icon: "handshake.fill", title: "Stakes") { Text("Stakes") },
                TabItem(icon: "person.text.rectangle", title: "Type") { Text("Type") },
                TabItem(icon: "person.3.fill", title: "Friends") { Text("Friends") },
                TabItem(icon: "person.fill", title: "Profile") { Text("Profile") }
            ]
        )
        .padding(.bottom, 34)
    }
    .background(Color(red: 130/255, green: 237/255, blue: 166/255))
}
