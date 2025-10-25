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
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "person.2.wave.2.fill")
                    .foregroundColor(theme.secondary)
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
}

// MARK: - Sheets (placeholders)
private struct RoomCreateSheet: View {
    @EnvironmentObject var roomManager: RoomViewModel
    var body: some View {
        VStack(spacing: 12) {
            Text("Create Room").font(.title2).bold()
            Button("Close") { roomManager.showCreateOverlay = false }
                .buttonStyle(NavPillStyle(variant: .outline))
        }
        .padding()
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
