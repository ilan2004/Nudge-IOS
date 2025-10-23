import SwiftUI

struct FriendCard: View {
    let friend: Friend
    var onTap: () -> Void
    var backgroundColor: Color? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            // Personality Initial/Avatar
            ZStack {
                Circle()
                    .fill(friend.personalityColors.primary.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Text(friend.personalityType.displayName.prefix(2).uppercased())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(friend.personalityColors.text)
            }
            
            // Friend Info
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(friend.relationshipType.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Circle()
                        .frame(width: 4, height: 4)
                        .foregroundColor(.secondary)
                    
                    Text(friend.personalityType.displayName)
                        .font(.caption)
                        .foregroundColor(friend.personalityColors.text)
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
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
.background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor ?? Color(.systemBackground))
                .shadow(color: friend.personalityColors.text.opacity(0.3), radius: 0, x: 0, y: 4)
                .shadow(color: friend.personalityColors.text.opacity(0.15), radius: 8, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(friend.personalityColors.primary, lineWidth: 2)
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
