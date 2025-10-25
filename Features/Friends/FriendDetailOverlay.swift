import SwiftUI

struct FriendDetailOverlay: View {
    let friend: Friend
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var friendsManager: FriendsManager
    
    @State private var showRemoveConfirmation = false
    @State private var showNudgeSheet = false
    @State private var isPerformingAction = false
    @State private var actionError: String?
    @State private var showProfileAlert = false
    
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
                
                // Top Section - Identity Header
                VStack(spacing: 12) {
                    ZStack {
                        Image(friend.avatarImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.guildBrown.opacity(0.5), lineWidth: 2))
                        
                        // Online status indicator
                        if friend.isOnline {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .offset(x: 40, y: 40)
                        }
                    }
                    
                    Text(friend.name)
                        .font(.custom("Tanker-Regular", size: 28))
                        .foregroundColor(Color.guildText)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                    
                    PersonalityBadge(personalityType: friend.personalityType, gender: friend.gender, guildCardStyle: true)
                        .padding(.top, 4)
                    
                    Text(friend.personalityType.displayName)
                        .font(.subheadline)
                        .foregroundColor(Color.guildTextSecondary)
                    
                    // Activity status
                    Text(activityStatusText)
                        .font(.caption)
                        .foregroundColor(friend.isOnline ? .green : .secondary)
                    
                    HStack(spacing: 10) {
                        // Relationship badge
                        Text(friend.relationshipType.displayName)
                            .font(.caption)
                            .foregroundColor(Color.guildText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.guildParchmentDark.opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.nudgeGreen900, lineWidth: 1)
                                    )
                            )
                        
                        // Rank indicator
                        HStack(spacing: 6) {
                            Image(systemName: "medal.fill")
                                .foregroundColor(Color.guildGoldDark)
                            Text("Rank #\(friend.rank)")
                                .font(.caption)
                                .foregroundColor(Color.guildTextSecondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.guildParchmentDark.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.nudgeGreen900, lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                DottedSeparator()
                    .padding(.horizontal, 16)
                
                // Stats Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Friend Stats")
                        .font(.custom("Tanker-Regular", size: 20))
                        .foregroundColor(Color.guildText)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        StatCard(
                            title: "Total Focus",
                            value: "\(friend.formattedTotalFocusHours)h",
                            icon: "clock.fill",
                            color: friend.personalityColors.primary
                        )
                        StatCard(
                            title: "Streak",
                            value: "\(friend.streakDays) days",
                            icon: "flame.fill",
                            color: friend.personalityColors.secondary
                        )
                        StatCard(
                            title: "Screen Time",
                            value: "\(friend.formattedDailyScreenTime)h",
                            icon: "hourglass",
                            color: friend.personalityColors.primary
                        )
                        StatCard(
                            title: "Avg Session",
                            value: "\(friend.avgSessionLengthMinutes)m",
                            icon: "timer",
                            color: friend.personalityColors.secondary
                        )
                        StatCard(
                            title: "Focus Points",
                            value: "\(friend.focusPoints)",
                            icon: "star.fill",
                            color: friend.personalityColors.primary
                        )
                        StatCard(
                            title: "Relationship",
                            value: friend.relationshipType.displayName,
                            icon: "person.2.fill",
                            color: friend.personalityColors.secondary
                        )
                    }
                }
                .padding(.horizontal, 16)
                
                DottedSeparator()
                    .padding(.horizontal, 16)
                
                // Activity Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Activity")
                        .font(.custom("Tanker-Regular", size: 20))
                        .foregroundColor(Color.guildText)
                    
                    if hasRecentActivity {
                        VStack(alignment: .leading, spacing: 8) {
                            if friend.isActive {
                                ActivityRow(icon: "bolt.fill", title: "Currently active", subtitle: "Now", color: .green)
                            }
                            if friend.streakDays > 0 {
                                ActivityRow(icon: "flame.fill", title: "Current streak: \(friend.streakDays) days", subtitle: formatFriendshipDuration(), color: friend.personalityColors.primary)
                            }
                            if friend.totalFocusHours > 0 {
                                ActivityRow(icon: "clock.fill", title: "Total focus: \(friend.formattedTotalFocusHours)h", subtitle: "All time", color: friend.personalityColors.secondary)
                            }
                        }
                    } else {
                        Text("No recent activity")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 16)
                
                DottedSeparator()
                    .padding(.horizontal, 16)
                
                // Actions Section
                VStack(spacing: 12) {
                    Button("Send Nudge") {
                        showNudgeSheet = true
                    }
                    .buttonStyle(NavPillStyle(variant: .primary))
                    .disabled(isPerformingAction)
                    
                    Button("View Profile") {
                        showProfileAlert = true
                    }
                    .buttonStyle(NavPillStyle(variant: .outline))
                    .disabled(isPerformingAction)
                    
                    Button("Remove Friend") {
                        showRemoveConfirmation = true
                    }
                    .buttonStyle(NavPillStyle(variant: .danger))
                    .disabled(isPerformingAction)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .padding(.bottom, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.guildParchment)
                .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.nudgeGreen900, lineWidth: 2)
                )
        )
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .edgesIgnoringSafeArea(.bottom)
        .overlay(alignment: .topTrailing) {
            // Close Button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color.guildBrown)
                    .padding(12)
            }
        }
        .confirmationDialog(
            "Remove \(friend.name)?",
            isPresented: $showRemoveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                Task {
                    await removeFriend()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You can always add them back later")
        }
        .alert("Profile", isPresented: $showProfileAlert) {
            Button("OK") { }
        } message: {
            Text("Full profile coming soon")
        }
        .alert("Error", isPresented: .constant(actionError != nil)) {
            Button("OK") {
                actionError = nil
            }
        } message: {
            if let error = actionError {
                Text(error)
            }
        }
        .sheet(isPresented: $showNudgeSheet) {
            SendNudgeView(friend: friend)
                .environmentObject(friendsManager)
                .presentationDetents([.height(500)])
        }
    }
    
    // MARK: - Helper Methods
    
    private var activityStatusText: String {
        if friend.isOnline {
            return "Active now"
        } else if let lastActive = friend.lastActive {
            let interval = Date().timeIntervalSince(lastActive)
            if interval < 3600 {
                let minutes = Int(interval / 60)
                return "Last seen \(minutes)m ago"
            } else if interval < 86400 {
                let hours = Int(interval / 3600)
                return "Last seen \(hours)h ago"
            } else {
                let days = Int(interval / 86400)
                return "Last seen \(days)d ago"
            }
        } else {
            return "Last seen unknown"
        }
    }
    
    private var hasRecentActivity: Bool {
        return friend.isActive || friend.streakDays > 0 || friend.totalFocusHours > 0
    }
    
    private func formatFriendshipDuration() -> String {
        let interval = friend.friendshipDuration
        let days = Int(interval / 86400)
        if days < 7 {
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else {
            let weeks = days / 7
            return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
        }
    }
    
    // MARK: - Actions
    
    @MainActor
    private func removeFriend() async {
        isPerformingAction = true
        
        do {
            try await friendsManager.removeFriend(friendId: friend.id)
            dismiss()
        } catch {
            actionError = "Failed to remove friend: \(error.localizedDescription)"
        }
        
        isPerformingAction = false
    }
}


private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14, weight: .semibold))
                Text(title.uppercased())
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(Color.guildTextSecondary)
            }
            Text(value)
                .font(.custom("Tanker-Regular", size: 22))
                .foregroundColor(Color.guildText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.defaultCream)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.nudgeGreen900.opacity(0.25), lineWidth: 1)
                        )
        )
    }
}

private struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(Color.guildText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color.guildTextSecondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

struct FriendDetailOverlay_Previews: PreviewProvider {
    static var previews: some View {
        FriendDetailOverlay(friend: Friend.mockFriends[0])
            .environmentObject(FriendsManager())
    }
}
