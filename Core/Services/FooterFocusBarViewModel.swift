import SwiftUI
import Combine
import UserNotifications

enum FocusMode {
    case idle
    case focus
    case paused
    case breakTime
}

final class FooterFocusBarViewModel: ObservableObject {
    @Published var mode: FocusMode = .idle
    @Published var remainingMs: Int = 0
    @Published var totalMs: Int = 0
    @Published var customMinutes: Int = 25

    @Published var selectedPreset: Int = 25

    private var timerCancellable: AnyCancellable?
    private var expectedEndDate: Date?

    // MARK: - Intents
    func setPreset(_ minutes: Int) {
        selectedPreset = minutes
        customMinutes = minutes
    }

    func start(minutes: Int? = nil) {
        let mins = minutes ?? customMinutes
        totalMs = max(1, mins) * 60_000
        remainingMs = totalMs
        mode = .focus
        scheduleTimer()
        scheduleEndNotification(afterSeconds: mins * 60)
        persistState(manuallyStopped: false, isBreak: false)
    }

    func pause() {
        guard mode == .focus else { return }
        mode = .paused
        timerCancellable?.cancel()
        expectedEndDate = nil
        persistState()
    }

    func resume() {
        guard mode == .paused else { return }
        mode = .focus
        scheduleTimer()
        scheduleEndNotification(afterMs: remainingMs)
        persistState()
    }

    func stop(manually: Bool = true) {
        timerCancellable?.cancel()
        mode = .idle
        expectedEndDate = nil
        remainingMs = 0
        clearState(manuallyStopped: manually)
    }

    func startBreak(minutes: Int = 5) {
        totalMs = max(1, minutes) * 60_000
        remainingMs = totalMs
        mode = .breakTime
        scheduleTimer()
        scheduleEndNotification(afterSeconds: minutes * 60)
        persistState(manuallyStopped: false, isBreak: true)
    }

    // MARK: - Timer
    private func scheduleTimer() {
        expectedEndDate = Date().addingTimeInterval(TimeInterval(remainingMs)/1000)
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func tick() {
        let now = Date()
        if let end = expectedEndDate {
            remainingMs = max(0, Int(end.timeIntervalSince(now) * 1000))
        } else {
            remainingMs = max(0, remainingMs - 1000)
        }
        if remainingMs == 0 { completeIfNeeded() }
    }

    // MARK: - Notifications
    private func scheduleEndNotification(afterSeconds: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Session Complete"
        content.body = mode == .breakTime ? "Break finished." : "Focus session finished."
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(max(1, afterSeconds)), repeats: false)
        let request = UNNotificationRequest(identifier: "nudge.session.end", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    private func scheduleEndNotification(afterMs: Int) {
        scheduleEndNotification(afterSeconds: max(1, afterMs/1000))
    }

    // MARK: - Persistence (lightweight)
    private func persistState(manuallyStopped: Bool? = nil, isBreak: Bool? = nil) {
        let d = UserDefaults.standard
        d.set(remainingMs, forKey: "Nudge_session_remaining_ms")
        d.set(totalMs, forKey: "Nudge_session_total_ms")
        d.set(modeKey(mode), forKey: "Nudge_session_mode")
        if let m = manuallyStopped { d.set(m, forKey: "Nudge_session_stopped") }
        if let b = isBreak { d.set(b, forKey: "Nudge_session_is_break") }
    }

    private func clearState(manuallyStopped: Bool) {
        let d = UserDefaults.standard
        d.set(manuallyStopped, forKey: "Nudge_session_stopped")
        d.removeObject(forKey: "Nudge_session_total_ms")
        d.removeObject(forKey: "Nudge_session_remaining_ms")
        d.removeObject(forKey: "Nudge_session_mode")
        d.removeObject(forKey: "Nudge_session_is_break")
    }

    private func completeIfNeeded() {
        timerCancellable?.cancel()
        // Log completion if not manually stopped
        let d = UserDefaults.standard
        let manuallyStopped = d.bool(forKey: "Nudge_session_stopped")
        if !manuallyStopped && mode == .focus && totalMs > 0 {
            let minutes = max(1, totalMs / 60_000)
            // TODO: append to daily log store for graphs
            _ = minutes // placeholder
        }
        mode = .idle
        expectedEndDate = nil
        clearState(manuallyStopped: false)
    }

    private func modeKey(_ m: FocusMode) -> String {
        switch m {
        case .idle: return "idle"
        case .focus: return "focus"
        case .paused: return "paused"
        case .breakTime: return "break"
        }
    }
}

