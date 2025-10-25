import SwiftUI


struct RoomsView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @EnvironmentObject var focusManager: FocusManager
    @EnvironmentObject var roomManager: RoomViewModel
    @StateObject private var restrictions = RestrictionsController()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Rooms")
                        .font(.custom("Tanker-Regular", size: 28))
                        .foregroundColor(personalityManager.currentTheme.text)
                    Spacer()
                    Button(action: { roomManager.showCreateOverlay = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                    .buttonStyle(NavPillStyle(variant: .primary))
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Active room indicator
                if let active = roomManager.activeRoom {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.horizontal.fill")
                                .foregroundColor(personalityManager.currentTheme.secondary)
                            Text("Active Session")
                                .font(.headline)
                                .foregroundColor(personalityManager.currentTheme.text)
                            Spacer()
                            Button("Join Session") { roomManager.showActiveSessionOverlay = true }
                                .buttonStyle(NavPillStyle(variant: .accent))
                        }
                        Text(active.name ?? "Focus Room")
                            .font(.subheadline)
                            .foregroundColor(personalityManager.currentTheme.textSecondary)
                    }
                    .padding(12)
                    .retroConsoleSurface()
                    .padding(.horizontal)
                }

                // Rooms list / empty state
                if roomManager.rooms.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "rectangle.stack.person.crop.fill")
                            .font(.system(size: 48))
                            .foregroundColor(personalityManager.currentTheme.secondary.opacity(0.8))
                        Text("Create Your First Room")
                            .font(.headline)
                            .foregroundColor(personalityManager.currentTheme.text)
                        Button("Create Room") { roomManager.showCreateOverlay = true }
                            .buttonStyle(NavPillStyle(variant: .primary))
                    }
                    .padding(16)
                    .retroConsoleSurface()
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                } else {
                    VStack(spacing: 12) {
                        ForEach(roomManager.rooms) { room in
                            RoomCard(room: room,
                                     theme: personalityManager.currentTheme,
                                     onTap: { roomManager.startRoomSession(roomId: room.id) })
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(maxWidth: 440)
        .onAppear {
            roomManager.attachServices(focusManager: focusManager, restrictions: restrictions)
            roomManager.loadRooms()
        }
        // Overlays
        .sheet(isPresented: $roomManager.showCreateOverlay) {
            RoomCreateSheet()
                .environmentObject(roomManager)
                .environmentObject(personalityManager)
        }
        .sheet(isPresented: $roomManager.showActiveSessionOverlay) {
            ActiveSessionSheet()
                .environmentObject(roomManager)
                .environmentObject(personalityManager)
        }
    }
}

// MARK: - Room Card
private struct RoomCard: View {
    let room: Room
    let theme: PersonalityColors
    let onTap: () -> Void
    
    private var memberFriends: [Friend] {
        let allFriends = Friend.mockFriends
        return room.memberIds.compactMap { memberId in
            allFriends.first { $0.id == memberId }
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Member avatars stack
                memberAvatarsView
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(room.name ?? "Focus Room").font(.headline).foregroundColor(theme.text)
                    Text("Members: \(room.memberIds.count)")
                        .font(.caption).foregroundColor(theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(theme.primary)
            }
            .padding(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .retroConsoleSurface()
    }
    
    private var memberAvatarsView: some View {
        HStack(spacing: -8) {
            ForEach(memberFriends.prefix(4)) { friend in
                Image(friend.avatarImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(friend.personalityColors.primary, lineWidth: 2)
                    )
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 36, height: 36)
                    )
            }
            
            if memberFriends.count > 4 {
                ZStack {
                    Circle()
                        .fill(Color.guildParchmentDark)
                        .frame(width: 32, height: 32)
                    Circle()
                        .stroke(Color.nudgeGreen900, lineWidth: 2)
                        .frame(width: 32, height: 32)
                    Text("+\(memberFriends.count - 4)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.nudgeGreen900)
                }
            }
        }
    }
}

// MARK: - Sheets
private struct RoomCreateSheet: View {
    @EnvironmentObject var roomManager: RoomViewModel
    @EnvironmentObject var personalityManager: PersonalityManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var roomName: String = ""
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Step indicator
                    stepIndicator
                    
                    // Content based on current step
                    switch roomManager.createFlowStep {
                    case .selectFriends:
                        friendSelectionStep
                    case .setSchedule:
                        scheduleStep
                    case .confirm:
                        confirmStep
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Navigation buttons
                    navigationButtons
                }
                .padding()
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        roomManager.resetCreateFlow()
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Step Indicator
    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(stepColor(for: index))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func stepColor(for index: Int) -> Color {
        let currentIndex = stepIndex(roomManager.createFlowStep)
        return index <= currentIndex ? personalityManager.currentTheme.primary : Color.gray.opacity(0.3)
    }
    
    private func stepIndex(_ step: RoomViewModel.CreateFlowStep) -> Int {
        switch step {
        case .selectFriends: return 0
        case .setSchedule: return 1
        case .confirm: return 2
        }
    }
    
    private var stepTitle: String {
        switch roomManager.createFlowStep {
        case .selectFriends: return "Select Friends"
        case .setSchedule: return "Set Schedule"
        case .confirm: return "Confirm Room"
        }
    }
    
    // MARK: - Step 1: Friend Selection
    private var friendSelectionStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Who's joining the room?")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Select 1 or more friends to invite")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(Friend.mockFriends) { friend in
                FriendSelectionRow(friend: friend, isSelected: roomManager.selectedFriends.contains(friend.id)) {
                    roomManager.toggleFriendSelection(friendId: friend.id)
                }
            }
        }
    }
    
    // MARK: - Step 2: Schedule
    private var scheduleStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("When should the room meet?")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DatePicker("Start Time", selection: $roomManager.scheduleStartTime, displayedComponents: .hourAndMinute)
                DatePicker("End Time", selection: $roomManager.scheduleEndTime, displayedComponents: .hourAndMinute)
            }
            .padding()
            .background(Color.guildParchment)
            .cornerRadius(12)
            
            Toggle("Repeat Daily", isOn: $roomManager.isRecurring)
                .padding()
                .background(Color.guildParchment)
                .cornerRadius(12)
            
            if roomManager.isRecurring {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Days")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    DaySelector(selectedDays: $roomManager.selectedDays)
                }
            }
        }
    }
    
    // MARK: - Step 3: Confirm
    private var confirmStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ready to create your room?")
                .font(.title3)
                .fontWeight(.semibold)
            
            TextField("Room Name (optional)", text: $roomName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color.guildParchment)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Summary")
                    .font(.headline)
                
                HStack {
                    Text("Members:")
                        .foregroundColor(.secondary)
                    Text("\(roomManager.selectedFriends.count)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Time:")
                        .foregroundColor(.secondary)
                    Text("\(formatTime(roomManager.scheduleStartTime)) - \(formatTime(roomManager.scheduleEndTime))")
                        .fontWeight(.semibold)
                }
                
                if roomManager.isRecurring {
                    HStack {
                        Text("Days:")
                            .foregroundColor(.secondary)
                        Text(formatDays(roomManager.selectedDays))
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding()
            .background(Color.guildParchment)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if roomManager.createFlowStep != .selectFriends {
                Button("Back") {
                    previousStep()
                }
                .buttonStyle(NavPillStyle(variant: .outline))
            }
            
            Spacer()
            
            if roomManager.createFlowStep == .confirm {
                Button(isCreating ? "Creating..." : "Create Room") {
                    createRoom()
                }
                .buttonStyle(NavPillStyle(variant: .primary))
                .disabled(isCreating || !canCreate)
            } else {
                Button("Next") {
                    nextStep()
                }
                .buttonStyle(NavPillStyle(variant: .primary))
                .disabled(!canProceed)
            }
        }
    }
    
    // MARK: - Validation
    private var canProceed: Bool {
        switch roomManager.createFlowStep {
        case .selectFriends:
            return !roomManager.selectedFriends.isEmpty
        case .setSchedule:
            return roomManager.validateSchedule() && (!roomManager.isRecurring || !roomManager.selectedDays.isEmpty)
        case .confirm:
            return true
        }
    }
    
    private var canCreate: Bool {
        !roomManager.selectedFriends.isEmpty && roomManager.validateSchedule()
    }
    
    // MARK: - Actions
    private func nextStep() {
        withAnimation {
            switch roomManager.createFlowStep {
            case .selectFriends:
                roomManager.createFlowStep = .setSchedule
            case .setSchedule:
                roomManager.createFlowStep = .confirm
            case .confirm:
                break
            }
        }
    }
    
    private func previousStep() {
        withAnimation {
            switch roomManager.createFlowStep {
            case .selectFriends:
                break
            case .setSchedule:
                roomManager.createFlowStep = .selectFriends
            case .confirm:
                roomManager.createFlowStep = .setSchedule
            }
        }
    }
    
    private func createRoom() {
        isCreating = true
        let schedule = RoomSchedule(
            startTime: roomManager.scheduleStartTime,
            endTime: roomManager.scheduleEndTime,
            daysOfWeek: roomManager.selectedDays,
            isRecurring: roomManager.isRecurring,
            timezone: .current
        )
        roomManager.createRoom(
            name: roomName.isEmpty ? nil : roomName,
            friendIds: Array(roomManager.selectedFriends),
            schedule: schedule
        )
        dismiss()
    }
    
    // MARK: - Helpers
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDays(_ days: Set<Int>) -> String {
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days.sorted().map { dayNames[$0] }.joined(separator: ", ")
    }
}

// MARK: - Friend Selection Row
private struct FriendSelectionRow: View {
    let friend: Friend
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(friend.avatarImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(friend.personalityColors.primary, lineWidth: 2)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.name)
                        .font(.headline)
                        .foregroundColor(Color.guildText)
                    Text(friend.personalityType.rawValue)
                        .font(.caption)
                        .foregroundColor(Color.guildTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .gray)
                    .font(.title3)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.guildParchment : Color.defaultCream)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.nudgeGreen900 : Color.nudgeGreen900.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct ActiveSessionSheet: View {
    @EnvironmentObject var roomManager: RoomViewModel
    var body: some View {
        VStack(spacing: 12) {
            Text("Active Session").font(.title2).bold()
            if let room = roomManager.activeRoom {
                Text(room.name ?? "Focus Room")
            }
            Button("End Session") {
                if let id = roomManager.activeRoom?.id { roomManager.endRoomSession(roomId: id) }
            }
            .buttonStyle(NavPillStyle(variant: .danger))
        }
        .padding()
    }
}

#Preview {
    RoomsView()
        .environmentObject(PersonalityManager())
        .environmentObject(FocusManager())
        .environmentObject(RoomViewModel())
}
