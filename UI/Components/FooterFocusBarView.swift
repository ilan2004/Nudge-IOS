// UI/Components/FooterFocusBarView.swift
import SwiftUI

// MARK: - ViewModel
class FooterFocusBarViewModel: ObservableObject {
    enum Mode {
        case idle, focus, paused, breakTime
    }
    
    @Published var mode: Mode = .idle
    @Published var remainingMs: Int = 0
    @Published var customMinutes: Int = 25
    @Published var selectedPreset: Int? = 25
    
    private var timer: Timer?
    private var targetMs: Int = 0
    
    func setPreset(_ minutes: Int) {
        selectedPreset = minutes
        customMinutes = minutes
    }
    
    func start() {
        mode = .focus
        targetMs = customMinutes * 60 * 1000
        remainingMs = targetMs
        startTimer()
    }
    
    func pause() {
        mode = .paused
        timer?.invalidate()
    }
    
    func resume() {
        mode = .focus
        startTimer()
    }
    
    func stop() {
        mode = .idle
        timer?.invalidate()
        remainingMs = 0
        selectedPreset = nil
    }
    
    func startBreak(minutes: Int) {
        mode = .breakTime
        targetMs = minutes * 60 * 1000
        remainingMs = targetMs
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingMs = max(0, self.remainingMs - 1000)
            if self.remainingMs <= 0 {
                self.stop()
            }
        }
    }
}

// MARK: - FooterFocusBarView
struct FooterFocusBarView: View {
    @StateObject private var vm = FooterFocusBarViewModel()
    @State private var showSettings = false

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width <= 600
            
            VStack(spacing: 6) {
                if isCompact {
                    compactLayout
                } else {
                    wideLayout
                }
            }
            .padding(.horizontal, isCompact ? 8 : 12)
            .padding(.vertical, isCompact ? 8 : 10)
            .retroConsoleSurface()
            .frame(maxWidth: geometry.size.width - 32)
        }
        .frame(height: vm.mode == .idle ? 60 : 80) // Adaptive height
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .animation(.easeInOut(duration: 0.2), value: vm.mode)
        .sheet(isPresented: $showSettings) {
            FocusSettingsView()
        }
    }
    
    // MARK: - Wide Layout (Desktop)
    private var wideLayout: some View {
        HStack(spacing: 6) {
            if vm.mode != .idle {
                statusChip
                countdown
            }
            
            if vm.mode == .idle {
                presets
                Spacer(minLength: 4)
                customMinutes
            }
            
            Spacer(minLength: 4)
            
            dynamicActionButtons
            
            settingsButton
        }
    }
    
    // MARK: - Compact Layout (Mobile)
    private var compactLayout: some View {
        VStack(spacing: 6) {
            // Top row: Status and primary actions
            HStack(spacing: 6) {
                if vm.mode != .idle {
                    statusChip
                    countdown
                }
                
                Spacer(minLength: 4)
                
                dynamicActionButtons
                
                settingsButton
            }
            
            // Bottom row: Only show presets when idle
            if vm.mode == .idle {
                HStack(spacing: 6) {
                    presets
                    Spacer(minLength: 4)
                    customMinutes
                }
            }
        }
    }
    
    // MARK: - Dynamic Action Buttons (State-based)
    @ViewBuilder
    private var dynamicActionButtons: some View {
        switch vm.mode {
        case .idle:
            // Idle: Just Start button
            Button("Start") { vm.start() }
                .buttonStyle(NavPillStyle(variant: .primary))
            
        case .focus:
            // Focus: Pause + Break
            Button("Pause") { vm.pause() }
                .buttonStyle(NavPillStyle(variant: .amber))
            
            Button("Break") { vm.startBreak(minutes: 5) }
                .buttonStyle(NavPillStyle(variant: .cyan, compact: true))
            
        case .paused:
            // Paused: Resume + Stop
            Button("Resume") { vm.resume() }
                .buttonStyle(NavPillStyle(variant: .primary))
            
            Button("Stop") { vm.stop() }
                .buttonStyle(NavPillStyle(variant: .accent, compact: true))
            
        case .breakTime:
            // Break: End Break button
            Button("End Break") { vm.stop() }
                .buttonStyle(NavPillStyle(variant: .cyan))
        }
    }

    // MARK: - UI Components
    private var statusChip: some View {
        Text(statusLabel)
            .font(.caption).bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(statusChipColor.opacity(0.3)))
            .foregroundColor(Color.nudgeGreen900)
    }

    private var countdown: some View {
        Text(formatMMSS(vm.remainingMs))
            .font(.system(.footnote, design: .monospaced).bold())
            .foregroundColor(Color.nudgeGreen900)
    }

    private var presets: some View {
        HStack(spacing: 4) {
            ForEach([25, 45, 60], id: \.self) { m in
                Button("\(m)") { vm.setPreset(m) }
                    .buttonStyle(NavPillStyle(variant: vm.selectedPreset == m ? .cyan : .outline, compact: true))
            }
        }
    }

    private var customMinutes: some View {
        HStack(spacing: 4) {
            Button(action: { vm.customMinutes = max(1, vm.customMinutes - 1) }) {
                Image(systemName: "minus.circle.fill")
                    .font(.caption)
            }
            .foregroundColor(Color.nudgeGreen900)
            
            Text("\(vm.customMinutes)m")
                .font(.caption2.bold())
                .lineLimit(1)
                .frame(minWidth: 28)
            
            Button(action: { vm.customMinutes = min(240, vm.customMinutes + 1) }) {
                Image(systemName: "plus.circle.fill")
                    .font(.caption)
            }
            .foregroundColor(Color.nudgeGreen900)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(.systemBackground))
                .overlay(
                    Capsule().stroke(Color.nudgeGreen900, lineWidth: 2)
                )
        )
    }

    private var settingsButton: some View {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.caption)
        }
        .buttonStyle(NavPillStyle(variant: .outline, compact: true))
    }

    // MARK: - Computed Properties
    private var statusLabel: String {
        switch vm.mode {
        case .idle: return "Idle"
        case .focus: return "Focus"
        case .paused: return "Paused"
        case .breakTime: return "Break"
        }
    }
    
    private var statusChipColor: Color {
        switch vm.mode {
        case .idle: return .gray
        case .focus: return Color(red: 0.24, green: 0.84, blue: 0.91)
        case .paused: return Color(red: 0.96, green: 0.69, blue: 0.13)
        case .breakTime: return Color(red: 0.24, green: 0.84, blue: 0.91)
        }
    }

    private func formatMMSS(_ ms: Int) -> String {
        guard ms > 0 else { return "00:00" }
        let total = ms / 1000
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Placeholder Settings View
struct FocusSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title.bold())
                    .foregroundColor(.nudgeGreen900)
                
                Text("Configure your focus session preferences here.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(NavPillStyle(variant: .primary))
            }
            .padding()
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        FooterFocusBarView()
    }
    .background(Color(red: 0.96, green: 0.96, blue: 0.94))
}