import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct MemberStatCard: View {
    let member: RoomMember
    let stats: RoomSessionStats
    let rank: Int
    let isCurrentUser: Bool
    
    @State private var animateRankChange = false
    @State private var celebrateSuccess = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        cardContent
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isCurrentUser ? Color.guildParchment : Color.defaultCream)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isCurrentUser ? Color.nudgeGreen900 : Color.nudgeGreen900.opacity(0.3), lineWidth: isCurrentUser ? 2 : 1)
                    )
                    .shadow(color: isCurrentUser ? Color.nudgeGreen900.opacity(0.3) : Color.clear, radius: isCurrentUser ? 8 : 0, x: 0, y: 4)
            )
            .statsPanelSurface()
            .scaleEffect(celebrateSuccess ? 1.05 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: celebrateSuccess)
            .onChange(of: rank) { oldValue, newValue in
                handleRankChange(oldValue: oldValue, newValue: newValue)
            }
            .onChange(of: focusPercentage) { oldValue, newValue in
                handleFocusPercentageChange(oldValue: oldValue, newValue: newValue)
            }
    }
    
    // MARK: - Card Content
    private var cardContent: some View {
        VStack(spacing: 12) {
            headerSection
            statsGrid
            progressSection
        }
        .padding(12)
    }
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            avatarView
            memberInfo
            Spacer()
            rankBadge
        }
    }
    
    private var avatarView: some View {
        Image(member.friend.avatarImageName)
            .resizable()
            .scaledToFill()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(member.friend.personalityColors.primary, lineWidth: 3)
            )
            .shadow(color: member.friend.personalityColors.primary.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var memberInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(member.friend.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.guildText)
                .lineLimit(1)
            
            personalityBadge
        }
    }
    
    private var personalityBadge: some View {
        Text(member.friend.personalityType.rawValue)
            .font(.caption2)
            .foregroundColor(Color.guildText)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(member.friend.personalityColors.primary.opacity(0.2))
            )
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            MemberStatItem(
                title: "Focus",
                value: formatTime(stats.focusTimeSeconds),
                icon: "clock.fill",
                color: .green
            )
            
            MemberStatItem(
                title: "Breaks",
                value: "\(stats.breakCount)",
                icon: "cup.and.saucer.fill",
                color: .cyan
            )
            
            MemberStatItem(
                title: "Screen",
                value: formatTime(stats.screenTimeSeconds),
                icon: "iphone.gen3",
                color: .orange
            )
            
            MemberStatItem(
                title: "Distractions",
                value: "\(stats.distractionCount)",
                icon: "exclamationmark.triangle.fill",
                color: .red
            )
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Focus Progress")
                    .font(.caption)
                    .foregroundColor(Color.guildTextSecondary)
                
                Spacer()
                
                Text("\(Int(focusPercentage * 100))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(progressColor)
            }
            
            progressBar
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(progressGradient)
                    .frame(width: geometry.size.width * CGFloat(focusPercentage), height: 8)
                    .cornerRadius(4)
                    .animation(.easeInOut(duration: 0.5), value: focusPercentage)
            }
        }
        .frame(height: 8)
    }
    
    
    // MARK: - Animation Handlers
    private func handleRankChange(oldValue: Int, newValue: Int) {
        if newValue < oldValue {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                animateRankChange = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateRankChange = false
            }
            
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
        }
    }
    
    private func handleFocusPercentageChange(oldValue: Double, newValue: Double) {
        let oldMilestone = Int(oldValue * 10)
        let newMilestone = Int(newValue * 10)
        
        if newMilestone > oldMilestone && newMilestone % 2 == 0 { // Every 20%
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                celebrateSuccess = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                celebrateSuccess = false
            }
            
            #if canImport(UIKit)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif
        }
    }
    
    // MARK: - Rank Badge
    private var rankBadge: some View {
        HStack(spacing: 4) {
            Text(rankEmoji)
                .font(.system(size: 16))
                .scaleEffect(animateRankChange ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: animateRankChange)
            
            if rank > 3 {
                Text("#\(rank)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.guildBrown)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(rankBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.guildBrown.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Computed Properties
    private var focusPercentage: Double {
        let totalTime = stats.focusTimeSeconds + stats.screenTimeSeconds
        guard totalTime > 0 else { return 0 }
        return Double(stats.focusTimeSeconds) / Double(totalTime)
    }
    
    private var progressColor: Color {
        if focusPercentage >= 0.8 {
            return .green
        } else if focusPercentage >= 0.5 {
            return .yellow
        } else {
            return .red
        }
    }
    
    private var progressGradient: LinearGradient {
        if focusPercentage >= 0.8 {
            return LinearGradient(
                colors: [Color.green.opacity(0.8), Color.green],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if focusPercentage >= 0.5 {
            return LinearGradient(
                colors: [Color.yellow.opacity(0.8), Color.yellow],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [Color.red.opacity(0.8), Color.red],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "🏅"
        }
    }
    
    private var rankBackgroundColor: Color {
        switch rank {
        case 1: return Color.yellow.opacity(0.3)
        case 2: return Color.gray.opacity(0.3)
        case 3: return Color.orange.opacity(0.3)
        default: return Color.guildParchmentDark.opacity(0.3)
        }
    }
    
    // MARK: - Helper Methods
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Member Stat Item Component
private struct MemberStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 12, weight: .semibold))
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(Color.guildTextSecondary)
            }
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.guildText)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    let mockMember = Room.mockMembers[0]
    let mockStats = RoomSessionStats(
        userId: mockMember.id,
        focusTimeSeconds: 3600,
        breakCount: 2,
        screenTimeSeconds: 1800,
        distractionCount: 3,
        lastUpdated: Date()
    )
    
    return VStack(spacing: 16) {
        MemberStatCard(
            member: mockMember,
            stats: mockStats,
            rank: 1,
            isCurrentUser: true
        )
        
        MemberStatCard(
            member: Room.mockMembers[1],
            stats: mockStats,
            rank: 2,
            isCurrentUser: false
        )
    }
    .padding()
    .background(Color.guildParchment)
    .environmentObject(PersonalityManager())
}
