import SwiftUI

struct FriendDetailOverlay: View {
    let friend: Friend
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.vertical, 8)
            
            // Header
            HStack(alignment: .top) {
                // Profile/Personality Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(friend.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        Text(friend.personalityType.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(friend.personalityColors.primary.opacity(0.2))
                            .foregroundColor(friend.personalityColors.text)
                            .cornerRadius(12)
                        
                        Text("Rank #\(friend.rank)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Close Button
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            // Stats Grid
            LazyVGrid(columns: columns, spacing: 16) {
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
                    title: "Avg. Session",
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
            .padding(.horizontal)
            .padding(.bottom, 24)
            
            Spacer()
        }
        .padding(.top, 8)
        .background(Color(.systemBackground))
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .edgesIgnoringSafeArea(.bottom)
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
                
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct FriendDetailOverlay_Previews: PreviewProvider {
    static var previews: some View {
        FriendDetailOverlay(friend: Friend.mockFriends[0])
            .preferredColorScheme(.dark)
    }
}
