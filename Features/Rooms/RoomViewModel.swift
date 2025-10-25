import Foundation
import Combine
import UserNotifications

final class RoomViewModel: ObservableObject {
    // MARK: - Published state
    @Published var rooms: [Room] = []
    @Published var activeRoom: Room? = nil
    @Published var selectedFriends: Set<UUID> = []
    @Published var showCreateOverlay: Bool = false
    @Published var showActiveSessionOverlay: Bool = false
    @Published var createFlowStep: CreateFlowStep = .selectFriends
    @Published var scheduleStartTime: Date
    @Published var scheduleEndTime: Date
    @Published var selectedDays: Set<Int> = []
    @Published var isRecurring: Bool = true

    // MARK: - Services
    private weak var focusManager: FocusManager?
    private var restrictionsController: RestrictionsController?

    // MARK: - Private runtime state
    private var timer: Timer?
    private var sessionStartTime: Date?

    // MARK: - Init
    init(now: Date = Date()) {
        let cal = Calendar.current
        let start = cal.date(bySettingHour: cal.component(.hour, from: now), minute: 0, second: 0, of: now) ?? now
        let end = cal.date(byAdding: .hour, value: 1, to: start) ?? now.addingTimeInterval(3600)
        self.scheduleStartTime = start
        self.scheduleEndTime = end
        self.rooms = []
    }

    // MARK: - Wire services
    func attachServices(focusManager: FocusManager, restrictions: RestrictionsController) {
        self.focusManager = focusManager
        self.restrictionsController = restrictions
    }

    // MARK: - Intents / API
    func loadRooms() {
        rooms = Room.mockRooms
    }

    func createRoom(name: String?, friendIds: [UUID], schedule: RoomSchedule) {
        let newRoom = Room(
            id: UUID(),
            name: name ?? "Focus Room",
            creatorId: friendIds.first ?? UUID(),
            memberIds: friendIds,
            schedule: schedule,
            isActive: false,
            createdAt: Date(),
            currentSessionId: nil
        )
        rooms.insert(newRoom, at: 0)
        resetCreateFlow()
        showCreateOverlay = false
    }

    func startRoomSession(roomId: UUID) {
        guard let idx = rooms.firstIndex(where: { $0.id == roomId }) else { return }
        activeRoom = rooms[idx]
        sessionStartTime = Date()
        startStatsTimer()
        focusManager?.startFocusSession()
        restrictionsController?.applyShields()
        showActiveSessionOverlay = true
    }

    func endRoomSession(roomId: UUID) {
        guard let current = activeRoom, current.id == roomId else { return }
        stopStatsTimer()
        focusManager?.endSession()
        restrictionsController?.clearShields()
        activeRoom = nil
        sessionStartTime = nil
        showActiveSessionOverlay = false
    }

    func updateSessionStats(roomId: UUID, stats: RoomSessionStats) {
        // In a real implementation, persist to backend; here we just log
        #if DEBUG
        print("Update stats for room: \(roomId) user: \(stats.userId) focus: \(stats.focusTimeSeconds)s")
        #endif
    }

    func deleteRoom(roomId: UUID) {
        rooms.removeAll { $0.id == roomId }
        if activeRoom?.id == roomId { activeRoom = nil }
    }

    func toggleFriendSelection(friendId: UUID) {
        if selectedFriends.contains(friendId) { selectedFriends.remove(friendId) } else { selectedFriends.insert(friendId) }
    }

    func validateSchedule() -> Bool {
        scheduleStartTime < scheduleEndTime
    }

    func resetCreateFlow() {
        selectedFriends.removeAll()
        createFlowStep = .selectFriends
        let cal = Calendar.current
        let start = cal.date(bySettingHour: cal.component(.hour, from: Date()), minute: 0, second: 0, of: Date()) ?? Date()
        let end = cal.date(byAdding: .hour, value: 1, to: start) ?? Date().addingTimeInterval(3600)
        scheduleStartTime = start
        scheduleEndTime = end
        selectedDays = []
        isRecurring = true
    }

    // MARK: - Timer
    private func startStatsTimer() {
        stopStatsTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            guard let self = self, let room = self.activeRoom else { return }
            // Emit a lightweight stat ping for demo purposes
            let uid = UUID() // In reality, current user id
            let stats = RoomSessionStats(userId: uid,
                                         focusTimeSeconds: Int.random(in: 30...120),
                                         breakCount: 0,
                                         screenTimeSeconds: Int.random(in: 10...60),
                                         distractionCount: Int.random(in: 0...2),
                                         lastUpdated: Date())
            self.updateSessionStats(roomId: room.id, stats: stats)
        }
    }

    private func stopStatsTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit { stopStatsTimer() }
}

// MARK: - Create Flow
extension RoomViewModel {
    enum CreateFlowStep { case selectFriends, setSchedule, confirm }
}

