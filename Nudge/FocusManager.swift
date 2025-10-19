import SwiftUI
import Combine
import UserNotifications

enum FocusState {
    case idle
    case focusing
    case onBreak
    case paused
}

class FocusManager: ObservableObject {
    @Published var currentState: FocusState = .idle
    @Published var remainingTime: TimeInterval = 0
    @Published var isActive: Bool = false
    @Published var currentSessionType: String = "Focus"
    @Published var totalFocusTime: TimeInterval = 0
    @Published var sessionsCompleted: Int = 0
    @Published var currentStreak: Int = 0
    
    private var timer: Timer?
    private var sessionStartTime: Date?
    
    var isRunning: Bool {
        return currentState == .focusing || currentState == .onBreak
    }
    
    var progress: Double {
        guard remainingTime > 0 else { return 0 }
        let totalTime = currentState == .focusing ? 25 * 60 : 5 * 60 // Default durations
        return 1.0 - (remainingTime / Double(totalTime))
    }
    
    func startFocusSession(duration: TimeInterval = 25 * 60) {
        currentState = .focusing
        remainingTime = duration
        currentSessionType = "Focus"
        isActive = true
        sessionStartTime = Date()
        
        startTimer()
        scheduleNotification(for: duration, title: "Focus Session Complete!", body: "Great job! Time for a break.")
    }
    
    func startBreakSession(duration: TimeInterval = 5 * 60) {
        currentState = .onBreak
        remainingTime = duration
        currentSessionType = "Break"
        sessionStartTime = Date()
        
        startTimer()
        scheduleNotification(for: duration, title: "Break Over!", body: "Ready to focus again?")
    }
    
    func pauseSession() {
        guard isRunning else { return }
        
        currentState = .paused
        stopTimer()
        cancelNotifications()
    }
    
    func resumeSession() {
        guard currentState == .paused else { return }
        
        if currentSessionType == "Focus" {
            currentState = .focusing
        } else {
            currentState = .onBreak
        }
        
        startTimer()
        scheduleNotification(for: remainingTime, title: "Session Complete!", body: "Time's up!")
    }
    
    func endSession() {
        let wasCompleted = remainingTime <= 0
        
        if wasCompleted && currentState == .focusing {
            sessionsCompleted += 1
            if let startTime = sessionStartTime {
                totalFocusTime += Date().timeIntervalSince(startTime)
            }
            
            // Update streak
            updateStreak()
        }
        
        stopTimer()
        cancelNotifications()
        
        currentState = .idle
        remainingTime = 0
        isActive = false
        sessionStartTime = nil
        
        // Auto-start break if focus session completed
        if wasCompleted && currentSessionType == "Focus" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.startBreakSession()
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimer() {
        remainingTime -= 1
        
        if remainingTime <= 0 {
            endSession()
        }
    }
    
    private func scheduleNotification(for duration: TimeInterval, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "focusSession", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error)")
            }
        }
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["focusSession"])
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastSessionKey = "lastFocusSessionDate"
        
        if let lastSessionData = UserDefaults.standard.object(forKey: lastSessionKey) as? Data,
           let lastSessionDate = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSDate.self, from: lastSessionData) as Date? {
            
            let lastSessionDay = calendar.startOfDay(for: lastSessionDate)
            let daysBetween = calendar.dateComponents([.day], from: lastSessionDay, to: today).day ?? 0
            
            if daysBetween == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysBetween > 1 {
                // Streak broken
                currentStreak = 1
            }
            // Same day = no change to streak
        } else {
            // First session ever
            currentStreak = 1
        }
        
        // Save today as last session date
        if let todayData = try? NSKeyedArchiver.archivedData(withRootObject: today, requiringSecureCoding: false) {
            UserDefaults.standard.set(todayData, forKey: lastSessionKey)
        }
        
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
    }
    
    func loadStats() {
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        sessionsCompleted = UserDefaults.standard.integer(forKey: "totalSessionsCompleted")
        totalFocusTime = UserDefaults.standard.double(forKey: "totalFocusTime")
    }
    
    func saveStats() {
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        UserDefaults.standard.set(sessionsCompleted, forKey: "totalSessionsCompleted")
        UserDefaults.standard.set(totalFocusTime, forKey: "totalFocusTime")
    }
    
    deinit {
        stopTimer()
        cancelNotifications()
    }
}
