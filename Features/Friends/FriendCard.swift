import SwiftUI

struct FriendCard: View {
    let friend: Friend
    var onTap: () -> Void
    var backgroundColor: Color? = nil
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar Photo with Online Status
            ZStack {
                Image(friend.avatarImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(friend.personalityColors.primary, lineWidth: 2)
                    )
                    .opacity(friend.isOnline ? 1.0 : 0.8)
                
                // Online status indicator
                if friend.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 20, y: -20)
                }
            }
            
            // Friend Info
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.custom("Tanker-Regular", size: 18))
                    .foregroundColor(friend.personalityColors.text)
                
                HStack(spacing: 8) {
                    Text(friend.relationshipType.displayName)
                        .font(.caption)
                        .foregroundColor(friend.personalityColors.textSecondary)
                    
                    Circle()
                        .frame(width: 4, height: 4)
                        .foregroundColor(friend.personalityColors.textSecondary)
                    
                    Text(friend.personalityType.displayName)
                        .font(.caption)
                        .foregroundColor(friend.personalityColors.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(friend.personalityColors.primary.opacity(0.2))
                        .cornerRadius(4)
                }
                
                // Last active status
                Text(lastActiveText)
                    .font(.caption2)
                    .foregroundColor(friend.isOnline ? .green : friend.personalityColors.textSecondary)
            }
            
            Spacer()
            
            // Focus Points with animation
            Button(action: onTap) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(friend.personalityColors.secondary)
                    
                    Text("\(friend.focusPoints)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(friend.personalityColors.text)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isPressed ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor ?? friend.personalityColors.background)
                .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    friend.relationshipType == .closeFriend ?
                        friend.personalityColors.primary :
                        Color.nudgeGreen900,
                    lineWidth: friend.relationshipType == .closeFriend ? 2.0 : 1.5
                )
        )
        .opacity(friend.isOnline ? 1.0 : 0.9)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                onTap()
            }
        }
        .accessibilityLabel(accessibilityText)
    }
    
    // MARK: - Helper Properties
    
    private var lastActiveText: String {
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
    
    private var accessibilityText: String {
        let status = friend.isOnline ? "online" : "offline"
        let relationship = friend.relationshipType.displayName.lowercased()
        return "\(friend.name), \(relationship), \(friend.personalityType.displayName), \(status), \(friend.focusPoints) focus points"
    }
}

struct FriendCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FriendCard(friend: Friend.mockFriends[0], onTap: {})
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Close Friend")
            
            FriendCard(friend: Friend.mockFriends[3], onTap: {})
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Acquaintance")
                .preferredColorScheme(.dark)
        }
    }
}
