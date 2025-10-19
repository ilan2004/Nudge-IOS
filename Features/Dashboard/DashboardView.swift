import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @EnvironmentObject var focusManager: FocusManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header with personality info
                    if let personalityType = personalityManager.personalityType {
                        PersonalityHeaderCard(personalityType: personalityType)
                    }
                    
                    // Focus Stats Card
                    FocusStatsCard()
                    
                    // Quick Actions
                    QuickActionsCard()
                    
                    // Recent Activity
                    RecentActivityCard()
                    
                    Spacer(minLength: 100) // Space for tab bar
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(personalityManager.currentTheme.background.ignoresSafeArea())
        }
    }
}

struct PersonalityHeaderCard: View {
    let personalityType: PersonalityType
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Hello, \(personalityType.displayName)!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(personalityType.rawValue)
                .font(.custom("Tanker-Regular", size: 24))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct FocusStatsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Focus")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatItem(title: "Sessions", value: "3", icon: "timer")
                StatItem(title: "Total Time", value: "2.5h", icon: "clock")
                StatItem(title: "Streak", value: "7 days", icon: "flame")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickActionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(title: "Start Focus", icon: "play.fill", color: .green)
                QuickActionButton(title: "Take Break", icon: "pause.fill", color: .orange)
                QuickActionButton(title: "View Stats", icon: "chart.bar", color: .blue)
                QuickActionButton(title: "Settings", icon: "gear", color: .gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // TODO: Add action
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
            )
        }
    }
}

struct RecentActivityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
            
            VStack(spacing: 12) {
                ActivityItem(title: "Completed 25min Focus Session", time: "2 hours ago", icon: "checkmark.circle.fill", color: .green)
                ActivityItem(title: "Started Deep Work Contract", time: "1 day ago", icon: "handshake.fill", color: .blue)
                ActivityItem(title: "Personality Assessment Completed", time: "3 days ago", icon: "person.fill", color: .purple)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct ActivityItem: View {
    let title: String
    let time: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(PersonalityManager())
        .environmentObject(FocusManager())
}
