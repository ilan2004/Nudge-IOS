import SwiftUI

struct FriendCard: View {
    let friend: Friend
    var onTap: () -> Void
    var backgroundColor: Color? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar Photo
            Image(friend.avatarImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
            
            // Friend Info
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.custom("Tanker-Regular", size: 18))
                    .foregroundColor(Color.guildText)
                
                HStack(spacing: 8) {
                    Text(friend.relationshipType.displayName)
                        .font(.caption)
                        .foregroundColor(Color.guildTextSecondary)
                    
                    Circle()
                        .frame(width: 4, height: 4)
                        .foregroundColor(Color.guildTextSecondary)
                    
                    Text(friend.personalityType.displayName)
                        .font(.caption)
                        .foregroundColor(Color.guildTextSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(friend.personalityColors.primary.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            // Focus Points
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(friend.personalityColors.secondary)
                
                Text("\(friend.focusPoints)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.guildText)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor ?? Color(.systemBackground))
                .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(friend.personalityColors.primary, lineWidth: 1.5)
        )
        .onTapGesture(perform: onTap)
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
