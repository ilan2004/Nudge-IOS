import SwiftUI

struct RoomDetailView: View {
    let room: Room
    @EnvironmentObject var roomManager: RoomViewModel
    @EnvironmentObject var personalityManager: PersonalityManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditingName = false
    @State private var editedRoomName = ""
    @State private var showEditSchedule = false
    @State private var showInviteFriends = false
    
    private let members: [RoomMember] = Room.mockMembers
    private let pastSessions: [PastSession] = PastSession.mockSessions
    
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
                
                // Members Section
                membersSection
                
                DottedSeparator()
                    .padding(.horizontal, 16)
                
                // Schedule Section
                scheduleSection
                
                DottedSeparator()
                    .padding(.horizontal, 16)
                
                // Session History Section
                sessionHistorySection
                
                DottedSeparator()
                    .padding(.horizontal, 16)
                
                // Action Buttons
                actionButtons
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
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
        .overlay(alignment: .topTrailing) {
            // Close Button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color.guildBrown)
                    .padding(12)
            }
        }
        .onAppear {
            editedRoomName = room.name ?? "Focus Room"
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Room icon/illustration
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.guildParchmentDark)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.guildBrown, lineWidth: 2)
                    )
                
                Image(systemName: "person.2.wave.2.fill")
                    .font(.system(size: 32))
                    .foregroundColor(personalityManager.currentTheme.secondary)
            }
            
            // Room name (editable)
            HStack(spacing: 8) {
                if isEditingName {
                    TextField("Room Name", text: $editedRoomName)
                        .font(.custom("Tanker-Regular", size: 28))
                        .foregroundColor(Color.guildText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            // Save edited name
                            isEditingName = false
                        }
                } else {
                    Text(room.name ?? "Focus Room")
                        .font(.custom("Tanker-Regular", size: 28))
                        .foregroundColor(Color.guildText)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    isEditingName.toggle()
                }) {
                    Image(systemName: isEditingName ? "checkmark.circle.fill" : "pencil.circle.fill")
                        .foregroundColor(Color.guildBrown)
                        .font(.title3)
                }
            }
            
            // Room info badges
            HStack(spacing: 12) {
                // Member count badge
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                    Text("\(room.memberIds.count) members")
                        .font(.caption)
                }
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
                
                // Created date
                Text("Created \(formatCreatedDate(room.createdAt))")
                    .font(.caption)
                    .foregroundColor(Color.guildTextSecondary)
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
        .padding(.horizontal, 16)
    }
    
    // MARK: - Members Section
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Room Members")
                    .font(.custom("Tanker-Regular", size: 20))
                    .foregroundColor(Color.guildText)
                
                Spacer()
                
                Button(action: {
                    showInviteFriends = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(personalityManager.currentTheme.primary)
                }
            }
            
            VStack(spacing: 8) {
                ForEach(members) { member in
                    MemberCard(member: member)
                }
            }
        }
    }
    
    // MARK: - Schedule Section
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Schedule")
                    .font(.custom("Tanker-Regular", size: 20))
                    .foregroundColor(Color.guildText)
                
                Spacer()
                
                Button("Edit Schedule") {
                    showEditSchedule = true
                }
                .buttonStyle(NavPillStyle(variant: .outline, compact: true))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Time range
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(personalityManager.currentTheme.secondary)
                        .font(.system(size: 16))
                    
                    Text(formatTimeRange(start: room.schedule.startTime, end: room.schedule.endTime))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.guildText)
                }
                
                // Days (if recurring)
                if room.schedule.isRecurring {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(personalityManager.currentTheme.secondary)
                            .font(.system(size: 16))
                        
                        Text(formatDays(room.schedule.daysOfWeek))
                            .font(.system(size: 16))
                            .foregroundColor(Color.guildText)
                    }
                }
                
                // Next session
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(personalityManager.currentTheme.accent)
                        .font(.system(size: 16))
                    
                    Text("Next: \(formatNextSession())")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.guildText)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.guildParchmentDark.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.nudgeGreen900.opacity(0.25), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Session History Section
    private var sessionHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Past Sessions")
                .font(.custom("Tanker-Regular", size: 20))
                .foregroundColor(Color.guildText)
            
            VStack(spacing: 8) {
                ForEach(pastSessions) { session in
                    SessionHistoryCard(session: session)
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Primary action - Start Session Now
            Button("Start Session Now") {
                roomManager.startRoomSession(roomId: room.id)
            }
            .buttonStyle(NavPillStyle(variant: .primary))
            .font(.system(size: 18, weight: .bold))
            .frame(height: 50)
            
            // Secondary actions
            HStack(spacing: 12) {
                Button("Edit Room") {
                    // Handle edit room
                }
                .buttonStyle(NavPillStyle(variant: .outline))
                
                Button("Leave Room") {
                    // Handle leave room
                }
                .buttonStyle(NavPillStyle(variant: .danger))
            }
            
            // Delete room (only for creator)
            if room.creatorId == currentUserId {
                Button("Delete Room") {
                    roomManager.deleteRoom(roomId: room.id)
                    dismiss()
                }
                .buttonStyle(NavPillStyle(variant: .danger))
                .font(.system(size: 14))
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatCreatedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    private func formatDays(_ days: Set<Int>) -> String {
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let sortedDays = days.sorted()
        return sortedDays.map { dayNames[$0] }.joined(separator: ", ")
    }
    
    private func formatNextSession() -> String {
        // Mock next session calculation
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return "Tomorrow at \(formatter.string(from: room.schedule.startTime))"
    }
    
    private var currentUserId: UUID {
        // In real app, this would be the actual current user ID
        room.creatorId
    }
}

// MARK: - Member Card
private struct MemberCard: View {
    let member: RoomMember
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Image(member.friend.avatarImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.guildBrown.opacity(0.3), lineWidth: 2))
            
            // Member info
            VStack(alignment: .leading, spacing: 4) {
                Text(member.friend.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.guildText)
                
                HStack(spacing: 8) {
                    // Personality type
                    Text(member.friend.personalityType.rawValue)
                        .font(.caption)
                        .foregroundColor(Color.guildText)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(member.friend.personalityColors.primary.opacity(0.2))
                        )
                    
                    // Online status
                    HStack(spacing: 4) {
                        Circle()
                            .fill(member.isOnline ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        
                        Text(member.isOnline ? "Online" : "Offline")
                            .font(.caption2)
                            .foregroundColor(Color.guildTextSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Last active
            VStack(alignment: .trailing, spacing: 2) {
                Text("Last active")
                    .font(.caption2)
                    .foregroundColor(Color.guildTextSecondary)
                
                Text(formatLastActive(member.sessionStats.lastUpdated))
                    .font(.caption)
                    .foregroundColor(Color.guildText)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.guildParchmentDark.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.nudgeGreen900.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    private func formatLastActive(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Session History Card
private struct SessionHistoryCard: View {
    let session: PastSession
    
    var body: some View {
        Button(action: {
            // Navigate to detailed session stats
        }) {
            HStack(spacing: 12) {
                // Date
                VStack(alignment: .leading, spacing: 2) {
                    Text(formatSessionDate(session.date))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.guildText)
                    
                    Text(formatSessionTime(session.date))
                        .font(.caption)
                        .foregroundColor(Color.guildTextSecondary)
                }
                
                Spacer()
                
                // Stats
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 16) {
                        VStack(alignment: .center, spacing: 2) {
                            Text("\(session.duration)m")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.guildText)
                            Text("Duration")
                                .font(.caption2)
                                .foregroundColor(Color.guildTextSecondary)
                        }
                        
                        VStack(alignment: .center, spacing: 2) {
                            Text("\(session.participantCount)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.guildText)
                            Text("Members")
                                .font(.caption2)
                                .foregroundColor(Color.guildTextSecondary)
                        }
                        
                        VStack(alignment: .center, spacing: 2) {
                            Text("\(session.avgFocusScore)%")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(focusScoreColor(session.avgFocusScore))
                            Text("Focus")
                                .font(.caption2)
                                .foregroundColor(Color.guildTextSecondary)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.guildBrown)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.guildParchmentDark.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.nudgeGreen900.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    private func formatSessionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatSessionTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func focusScoreColor(_ score: Int) -> Color {
        if score >= 80 {
            return .green
        } else if score >= 60 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Past Session Model
private struct PastSession: Identifiable {
    let id = UUID()
    let date: Date
    let duration: Int // minutes
    let participantCount: Int
    let avgFocusScore: Int // percentage
    
    static let mockSessions: [PastSession] = [
        PastSession(date: Date().addingTimeInterval(-86400), duration: 60, participantCount: 3, avgFocusScore: 85),
        PastSession(date: Date().addingTimeInterval(-172800), duration: 45, participantCount: 2, avgFocusScore: 72),
        PastSession(date: Date().addingTimeInterval(-259200), duration: 90, participantCount: 4, avgFocusScore: 91),
        PastSession(date: Date().addingTimeInterval(-345600), duration: 30, participantCount: 3, avgFocusScore: 67)
    ]
}

#Preview {
    RoomDetailView(room: Room.mockRooms[0])
        .environmentObject(RoomViewModel())
        .environmentObject(PersonalityManager())
}
