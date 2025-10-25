import SwiftUI
import Combine
import UserNotifications

class RoomManager: ObservableObject {
    // MARK: - Published Properties
    @Published var rooms: [Room] = []
    @Published var activeSession: RoomSession?
    @Published var currentRoomStats: [UUID: RoomSessionStats] = [:]
    @Published var isSessionActive: Bool = false
    
    // MARK: - Private Properties
    private let apiClient: APIClient
    private let userIdProvider: UserIdProvider.Type
    private var statsUpdateTimer: Timer?
    private var sessionStartTime: Date?
    
    // MARK: - UserDefaults Keys
    private let roomsKey = "nudge_rooms"
    private let activeSessionKey = "nudge_active_session"
    
    // MARK: - Initialization
    init(apiClient: APIClient = .shared, userIdProvider: UserIdProvider.Type = UserIdProvider.self) {
        self.apiClient = apiClient
        self.userIdProvider = userIdProvider
        
        loadRoomsFromCache()
        setupAppLifecycleObservers()
    }
    
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    // MARK: - Public Methods
    
    /// Load rooms from API and cache locally
    func loadRooms() async throws {
        let userId = userIdProvider.getOrCreate()
        let fetchedRooms = try await apiClient.getRooms(userId: userId)
        
        await MainActor.run {
            self.rooms = fetchedRooms
            self.saveRoomsToCache()
        }
    }
    
    /// Create new room via API
    func createRoom(name: String?, memberIds: [UUID], schedule: RoomSchedule) async throws -> Room {
        let userId = userIdProvider.getOrCreate()
        let memberIdStrings = memberIds.map { $0.uuidString }
        
        let room = try await apiClient.createRoom(
            userId: userId,
            name: name,
            memberIds: memberIdStrings,
            schedule: schedule
        )
        
        await MainActor.run {
            self.rooms.append(room)
            self.saveRoomsToCache()
        }
        
        return room
    }
    
    /// Update room details
    func updateRoom(roomId: UUID, name: String?, schedule: RoomSchedule?) async throws -> Room {
        let updatedRoom = try await apiClient.updateRoom(
            roomId: roomId.uuidString,
            name: name,
            schedule: schedule
        )
        
        await MainActor.run {
            if let index = self.rooms.firstIndex(where: { $0.id == roomId }) {
                self.rooms[index] = updatedRoom
                self.saveRoomsToCache()
            }
        }
        
        return updatedRoom
    }
    
    /// Delete room via API
    func deleteRoom(roomId: UUID) async throws {
        try await apiClient.deleteRoom(roomId: roomId.uuidString)
        
        await MainActor.run {
            self.rooms.removeAll { $0.id == roomId }
            self.saveRoomsToCache()
        }
    }
    
    /// Start a collaborative session
    func startSession(roomId: UUID) async throws {
        let userId = userIdProvider.getOrCreate()
        
        // Call API to start session
        let session = try await apiClient.startRoomSession(
            roomId: roomId.uuidString,
            userId: userId
        )
        
        await MainActor.run {
            self.activeSession = session
            self.isSessionActive = true
            self.sessionStartTime = Date()
            self.saveActiveSessionToCache()
            
            // Start stats update timer (every 10 seconds)
            self.startStatsUpdateTimer()
            
            // Schedule local notification for session end (assuming 25-minute default)
            self.scheduleSessionEndNotification()
        }
        
        // Notify FocusManager to start timer
        NotificationCenter.default.post(
            name: NSNotification.Name("StartFocusTimer"),
            object: nil
        )
        
        // Activate smart blocking via RestrictionsController
        NotificationCenter.default.post(
            name: NSNotification.Name("ActivateSmartBlocking"),
            object: nil
        )
    }
    
    /// End current session
    func endSession() async throws {
        guard let session = activeSession,
              let startTime = sessionStartTime else {
            return
        }
        
        let userId = userIdProvider.getOrCreate()
        let finalStats = calculateSessionStats()
        
        // Stop stats update timer
        await MainActor.run {
            self.stopStatsUpdateTimer()
        }
        
        // Call API to end session with final stats
        _ = try await apiClient.endRoomSession(
            roomId: session.roomId.uuidString,
            sessionId: session.id.uuidString,
            userId: userId,
            stats: finalStats
        )
        
        await MainActor.run {
            self.activeSession = nil
            self.isSessionActive = false
            self.sessionStartTime = nil
            self.currentRoomStats.removeAll()
            self.clearActiveSessionFromCache()
            
            // Show completion notification
            self.showSessionCompletionNotification()
        }
        
        // Notify FocusManager to stop timer
        NotificationCenter.default.post(
            name: NSNotification.Name("StopFocusTimer"),
            object: nil
        )
        
        // Deactivate smart blocking
        NotificationCenter.default.post(
            name: NSNotification.Name("DeactivateSmartBlocking"),
            object: nil
        )
    }
    
    /// Update member stats during session
    func updateStats(userId: UUID, stats: RoomSessionStats) async throws {
        guard let session = activeSession else {
            throw URLError(.badServerResponse) // or custom error
        }
        
        try await apiClient.updateSessionStats(
            roomId: session.roomId.uuidString,
            sessionId: session.id.uuidString,
            userId: userId.uuidString,
            stats: stats
        )
        
        await MainActor.run {
            self.currentRoomStats[userId] = stats
        }
    }
    
    /// Get current stats for all members
    func fetchLiveStats() async throws {
        guard let session = activeSession else { return }
        
        let statsDict = try await apiClient.getSessionStats(
            roomId: session.roomId.uuidString,
            sessionId: session.id.uuidString
        )
        
        await MainActor.run {
            // Convert string keys back to UUIDs
            self.currentRoomStats = Dictionary(uniqueKeysWithValues: 
                statsDict.compactMap { (key, value) -> (UUID, RoomSessionStats)? in
                    guard let uuid = UUID(uuidString: key) else { return nil }
                    return (uuid, value)
                }
            )
        }
    }
    
    /// Calculate current user's stats
    func calculateSessionStats() -> RoomSessionStats {
        let userId = UUID(uuidString: userIdProvider.getOrCreate()) ?? UUID()
        
        // Get stats from FocusManager (would need to access via notification or shared state)
        let focusTimeSeconds = getFocusTimeFromManager()
        let breakCount = getBreakCountFromManager()
        
        // Get screen time from device usage (placeholder implementation)
        let screenTimeSeconds = getScreenTimeSeconds()
        
        // Get distraction count from app unlock tracking (placeholder implementation)
        let distractionCount = getDistractionCount()
        
        return RoomSessionStats(
            userId: userId,
            focusTimeSeconds: focusTimeSeconds,
            breakCount: breakCount,
            screenTimeSeconds: screenTimeSeconds,
            distractionCount: distractionCount,
            lastUpdated: Date()
        )
    }
    
    // MARK: - Private Methods
    
    private func loadRoomsFromCache() {
        if let data = UserDefaults.standard.data(forKey: roomsKey),
           let cachedRooms = try? JSONDecoder().decode([Room].self, from: data) {
            self.rooms = cachedRooms
        }
        
        // Load active session
        if let data = UserDefaults.standard.data(forKey: activeSessionKey),
           let cachedSession = try? JSONDecoder().decode(RoomSession.self, from: data) {
            self.activeSession = cachedSession
            self.isSessionActive = true
        }
    }
    
    private func saveRoomsToCache() {
        if let data = try? JSONEncoder().encode(rooms) {
            UserDefaults.standard.set(data, forKey: roomsKey)
        }
    }
    
    private func saveActiveSessionToCache() {
        if let session = activeSession,
           let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: activeSessionKey)
        }
    }
    
    private func clearActiveSessionFromCache() {
        UserDefaults.standard.removeObject(forKey: activeSessionKey)
    }
    
    private func startStatsUpdateTimer() {
        statsUpdateTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task {
                do {
                    try await self?.updateCurrentUserStats()
                } catch {
                    print("Failed to update stats: \(error)")
                }
            }
        }
    }
    
    private func stopStatsUpdateTimer() {
        statsUpdateTimer?.invalidate()
        statsUpdateTimer = nil
    }
    
    private func updateCurrentUserStats() async throws {
        let userId = UUID(uuidString: userIdProvider.getOrCreate()) ?? UUID()
        let stats = calculateSessionStats()
        try await updateStats(userId: userId, stats: stats)
    }
    
    private func scheduleSessionEndNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete!"
        content.body = "Great job focusing with your team!"
        content.sound = .default
        
        // Schedule for 25 minutes (default session length)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 25 * 60, repeats: false)
        let request = UNNotificationRequest(
            identifier: "roomSessionEnd",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Session end notification scheduling error: \(error)")
            }
        }
    }
    
    private func showSessionCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Session Complete!"
        content.body = "Congratulations on completing your focus session!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "sessionComplete",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Completion notification error: \(error)")
            }
        }
    }
    
    // MARK: - App Lifecycle
    
    @objc private func appDidEnterBackground() {
        // Save current state
        saveRoomsToCache()
        if activeSession != nil {
            saveActiveSessionToCache()
        }
    }
    
    @objc private func appWillEnterForeground() {
        // Refresh live stats if session is active
        if isSessionActive {
            Task {
                try await fetchLiveStats()
            }
        }
    }
    
    // MARK: - Integration Helpers (Placeholder implementations)
    
    private func getFocusTimeFromManager() -> Int {
        // This would integrate with FocusManager to get actual focus time
        // For now, calculate based on session start time
        guard let startTime = sessionStartTime else { return 0 }
        return max(0, Int(Date().timeIntervalSince(startTime)))
    }
    
    private func getBreakCountFromManager() -> Int {
        // This would integrate with FocusManager to get actual break count
        // Placeholder implementation
        return 0
    }
    
    private func getScreenTimeSeconds() -> Int {
        // This would integrate with device usage APIs if available
        // Placeholder implementation
        return 0
    }
    
    private func getDistractionCount() -> Int {
        // This would integrate with app unlock tracking
        // Placeholder implementation
        return 0
    }
    
    // MARK: - Cleanup
    
    deinit {
        stopStatsUpdateTimer()
        NotificationCenter.default.removeObserver(self)
    }
}
