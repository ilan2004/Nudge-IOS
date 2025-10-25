import SwiftUI

struct ActiveSessionOverlay: View {
    @EnvironmentObject var roomManager: RoomViewModel
    @EnvironmentObject var personalityManager: PersonalityManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var sessionStartTime = Date()
    @State private var currentTime = Date()
    @State private var statsTimer: Timer?
    @State private var pulseAnimation = false
    @State private var memberStats: [RoomMember] = []
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Drag indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.guildBrown.opacity(0.25))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                
                // Header Section
                headerSection
                
                DottedSeparator()
                    .padding(.horizontal, 16)
                
                // Member Stats Section
                memberStatsSection
                
                DottedSeparator()
                    .padding(.horizontal, 16)
                
                // Leaderboard Section
                leaderboardSection
                
                DottedSeparator()
                    .padding(.horizontal, 16)
                
                // Action Buttons
                actionButtons
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.guildParchment)
                .parchmentTexture()
                .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.nudgeGreen900, lineWidth: 2)
                )
        )
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .onAppear {
            setupSession()
            startStatsTimer()
        }
        .onDisappear {
            stopStatsTimer()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(roomManager.activeRoom?.name ?? "Focus Room")
                        .font(.custom("Tanker-Regular", size: 24))
                        .foregroundColor(Color.guildText)
                    
                    HStack(spacing: 8) {
                        // LIVE badge with pulsing animation
                        Text("LIVE")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.red)
                                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                                    .opacity(pulseAnimation ? 0.8 : 1.0)
                            )
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulseAnimation)
                        
                        Text("\(memberStats.count) members")
                            .font(.caption)
                            .foregroundColor(Color.guildTextSecondary)
                    }
                }
                
                Spacer()
                
                // Session timer
                timerSquare(elapsedTime: sessionElapsedTime)
                    .frame(width: 120, height: 60)
            }
        }
    }
    
    // MARK: - Member Stats Section
    private var memberStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Battle Stats")
                .font(.custom("Tanker-Regular", size: 20))
                .foregroundColor(Color.guildText)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(memberStats) { member in
                    MemberStatCard(
                        member: member,
                        totalSessionTime: sessionElapsedTime
                    )
                    .statsPanelSurface()
                }
            }
        }
    }
    
    // MARK: - Leaderboard Section
    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Rankings")
                .font(.custom("Tanker-Regular", size: 20))
                .foregroundColor(Color.guildText)
            
            VStack(spacing: 8) {
                ForEach(Array(sortedMembers.enumerated()), id: \.element.id) { index, member in
                    LeaderboardRow(
                        member: member,
                        rank: index + 1,
                        isCurrentUser: member.id == currentUserId
                    )
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button("Take Break") {
                // Handle take break
            }
            .buttonStyle(NavPillStyle(variant: .cyan))
            
            HStack(spacing: 12) {
                Button("End Session") {
                    if let roomId = roomManager.activeRoom?.id {
                        roomManager.endRoomSession(roomId: roomId)
                    }
                }
                .buttonStyle(NavPillStyle(variant: .danger))
                
                Button("Minimize") {
                    dismiss()
                }
                .buttonStyle(NavPillStyle(variant: .outline))
            }
        }
    }
    
    // MARK: - Helper Views
    private func timerSquare(elapsedTime: TimeInterval) -> some View {
        let totalSeconds = Int(elapsedTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        let timeString = hours > 0 
            ? String(format: "%d:%02d:%02d", hours, minutes, seconds)
            : String(format: "%02d:%02d", minutes, seconds)
        
        return ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.nudgeGreen900, lineWidth: 4)
                )
                .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
            
            Text(timeString)
                .font(.custom("Nippo-Regular", size: 18, relativeTo: .title3))
                .foregroundColor(Color.nudgeGreen900)
                .monospacedDigit()
        }
    }
    
    // MARK: - Computed Properties
    private var sessionElapsedTime: TimeInterval {
        currentTime.timeIntervalSince(sessionStartTime)
    }
    
    private var sortedMembers: [RoomMember] {
        memberStats.sorted { $0.sessionStats.focusTimeSeconds > $1.sessionStats.focusTimeSeconds }
    }
    
    private var currentUserId: UUID {
        // In real app, this would be the actual current user ID
        memberStats.first?.id ?? UUID()
    }
    
    // MARK: - Helper Methods
    private func setupSession() {
        sessionStartTime = Date()
        currentTime = Date()
        pulseAnimation = true
        
        // Initialize with mock data - in real app, this would come from room manager
        memberStats = Room.mockMembers
    }
    
    private func startStatsTimer() {
        statsTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentTime = Date()
                updateMemberStats()
            }
        }
    }
    
    private func stopStatsTimer() {
        statsTimer?.invalidate()
        statsTimer = nil
    }
    
    private func updateMemberStats() {
        // Simulate real-time stat updates
        for i in memberStats.indices {
            memberStats[i].sessionStats.focusTimeSeconds += Int.random(in: 0...120)
            memberStats[i].sessionStats.screenTimeSeconds += Int.random(in: 0...60)
            memberStats[i].sessionStats.distractionCount += Int.random(in: 0...1)
            memberStats[i].sessionStats.lastUpdated = Date()
        }
        
        // Check for milestone achievements and provide haptic feedback
        checkMilestones()
    }
    
    private func checkMilestones() {
        let elapsed = sessionElapsedTime
        if Int(elapsed) % 3600 == 0 && elapsed > 0 { // Every hour
            #if canImport(UIKit)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif
        }
    }
}

// MARK: - Member Stat Card
private struct MemberStatCard: View {
    let member: RoomMember
    let totalSessionTime: TimeInterval
    
    var body: some View {
        VStack(spacing: 12) {
            // Avatar and name
            VStack(spacing: 6) {
                Image(member.friend.avatarImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.guildBrown.opacity(0.3), lineWidth: 2))
                
                Text(member.friend.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.guildText)
                    .lineLimit(1)
                
                PersonalityBadge(
                    personalityType: member.friend.personalityType,
                    gender: member.friend.gender,
                    guildCardStyle: true
                )
                .scaleEffect(0.8)
            }
            
            // Stats grid
            VStack(spacing: 6) {
                HStack {
                    StatItem(title: "Focus", value: formatTime(member.sessionStats.focusTimeSeconds))
                    StatItem(title: "Breaks", value: "\(member.sessionStats.breakCount)")
                }
                
                HStack {
                    StatItem(title: "Screen", value: formatTime(member.sessionStats.screenTimeSeconds))
                    StatItem(title: "Distractions", value: "\(member.sessionStats.distractionCount)")
                }
            }
            
            // Progress bar
            let focusPercentage = totalSessionTime > 0 
                ? Double(member.sessionStats.focusTimeSeconds) / totalSessionTime 
                : 0
            
            VStack(spacing: 4) {
                Text("Focus: \(Int(focusPercentage * 100))%")
                    .font(.caption2)
                    .foregroundColor(Color.guildTextSecondary)
                
                ProgressView(value: focusPercentage)
                    .progressViewStyle(FocusProgressStyle(percentage: focusPercentage))
            }
        }
        .padding(12)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let mins = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
}

// MARK: - Stat Item
private struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(Color.guildTextSecondary)
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.guildText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Focus Progress Style
private struct FocusProgressStyle: ProgressViewStyle {
    let percentage: Double
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 6)
                    .cornerRadius(3)
                
                Rectangle()
                    .fill(progressColor)
                    .frame(width: geometry.size.width * CGFloat(percentage), height: 6)
                    .cornerRadius(3)
                    .animation(.easeInOut(duration: 0.5), value: percentage)
            }
        }
        .frame(height: 6)
    }
    
    private var progressColor: Color {
        if percentage >= 0.8 {
            return .green
        } else if percentage >= 0.5 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Leaderboard Row
private struct LeaderboardRow: View {
    let member: RoomMember
    let rank: Int
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank medal
            Text(rankEmoji)
                .font(.title2)
            
            // Avatar
            Image(member.friend.avatarImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            // Name and stats
            VStack(alignment: .leading, spacing: 2) {
                Text(member.friend.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.guildText)
                
                Text("Focus: \(formatTime(member.sessionStats.focusTimeSeconds))")
                    .font(.caption)
                    .foregroundColor(Color.guildTextSecondary)
            }
            
            Spacer()
            
            Text("#\(rank)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.guildBrown)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentUser ? Color.guildParchmentDark.opacity(0.8) : Color.clear)
        )
    }
    
    private var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "🏅"
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let mins = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
}

// MARK: - Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ActiveSessionOverlay()
        .environmentObject(RoomViewModel())
        .environmentObject(PersonalityManager())
}
