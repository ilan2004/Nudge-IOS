import SwiftUI

struct FriendDetailOverlay: View {
    let friend: Friend
    @Environment(\.dismiss) private var dismiss
    
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
                    Image(friend.avatarImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.guildBrown.opacity(0.5), lineWidth: 2))
                    
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
                
                // Activity Section (Optional)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Activity")
                        .font(.custom("Tanker-Regular", size: 20))
                        .foregroundColor(Color.guildText)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ActivityRow(icon: "bolt.fill", title: "Focused 45m", subtitle: "Today", color: friend.personalityColors.primary)
                        ActivityRow(icon: "clock", title: "Focused 1h 20m", subtitle: "Yesterday", color: friend.personalityColors.secondary)
                        ActivityRow(icon: "flame.fill", title: "Streak reached \(friend.streakDays) days", subtitle: "This week", color: friend.personalityColors.accent)
                    }
                }
                .padding(.horizontal, 16)
                
                DottedSeparator()
                    .padding(.horizontal, 16)
                
                // Actions Section
                VStack(spacing: 12) {
                    Button("Send Nudge") {}
                        .buttonStyle(NavPillStyle(variant: .primary))
                    Button("View Profile") {}
                        .buttonStyle(NavPillStyle(variant: .outline))
                    Button("Remove Friend") {}
                        .buttonStyle(NavPillStyle(variant: .danger))
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
        // Top-edge primary green shadow (like navbar/tab bar)
        .overlay(alignment: .top) {
            ZStack {
                LinearGradient(colors: [Color.nudgeGreen900.opacity(0.45), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 14)
                LinearGradient(colors: [Color.nudgeGreen900.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 36)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .allowsHitTesting(false)
            .zIndex(1)
        }
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
    }
}
