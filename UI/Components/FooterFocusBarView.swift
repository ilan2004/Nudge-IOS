// UI/Components/FooterFocusBarView.swift
import SwiftUI


// MARK: - FooterFocusBarView
struct FooterFocusBarView: View {
    @StateObject private var vm = FooterFocusBarViewModel()
    @State private var showSettings = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                if geometry.size.width > 600 {
                    // Wide layout: single row
                    HStack(spacing: 6) {
                        statusChip
                        countdown
                        presets
                        Spacer(minLength: 4)
                        customMinutes
                        primaryAction
                        stopButton
                        breakButton
                        settingsButton
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .retroConsoleSurface()
                } else {
                    // Narrow layout: two rows
                    VStack(spacing: 6) {
                        // Top row: status and main controls
                        HStack(spacing: 6) {
                            statusChip
                            countdown
                            Spacer(minLength: 4)
                            primaryAction
                            stopButton
                            settingsButton
                        }
                        
                        // Bottom row: presets and additional controls
                        HStack(spacing: 6) {
                            presets
                            Spacer(minLength: 4)
                            customMinutes
                            breakButton
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .retroConsoleSurface()
                }
            }
            .frame(maxWidth: geometry.size.width - 32) // Respect container bounds
        }
        .frame(height: 80) // Fixed height to prevent layout shifts
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .sheet(isPresented: $showSettings) {
            FocusSettingsView()
        }
    }

    private var statusChip: some View {
        Text(statusLabel)
            .font(.caption).bold()
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(Capsule().fill(statusChipColor.opacity(0.3)))
            .foregroundColor(Color.nudgeGreen900)
    }

    private var countdown: some View {
        Text(formatMMSS(vm.remainingMs))
            .font(.system(.footnote, design: .monospaced))
            .foregroundColor(.secondary)
    }

    private var presets: some View {
        HStack(spacing: 6) {
            ForEach([25, 45, 60], id: \.self) { m in
                Button("\(m)m") { vm.setPreset(m) }
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
                .frame(minWidth: 30)
            
            Button(action: { vm.customMinutes = min(240, vm.customMinutes + 1) }) {
                Image(systemName: "plus.circle.fill")
                    .font(.caption)
            }
            .foregroundColor(Color.nudgeGreen900)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(.systemBackground))
                .overlay(
                    Capsule().stroke(Color.nudgeGreen900, lineWidth: 2)
                )
        )
    }

    private var primaryAction: some View {
        Button(primaryLabel) {
            switch (vm.mode) {
            case .idle: vm.start()
            case .paused: vm.resume()
            case .focus, .breakTime: vm.pause()
            }
        }
        .buttonStyle(NavPillStyle(variant: primaryVariant))
    }

    private var stopButton: some View {
        Button("Stop") { vm.stop() }
            .buttonStyle(NavPillStyle(variant: .accent))
    }

    private var breakButton: some View {
        Button("Break 5m") { vm.startBreak(minutes: 5) }
            .buttonStyle(NavPillStyle(variant: .cyan))
    }

    private var settingsButton: some View {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
        .buttonStyle(NavPillStyle(variant: .outline, compact: true))
    }

    private var primaryLabel: String {
        switch vm.mode {
        case .idle: return "Start"
        case .paused: return "Resume"
        case .focus, .breakTime: return "Pause"
        }
    }

    private var primaryVariant: PillVariant {
        switch vm.mode {
        case .idle, .paused: return .primary // Start/Resume -> green primary
        case .focus, .breakTime: return .amber // Pause -> amber
        }
    }

    private var statusLabel: String {
        switch vm.mode {
        case .idle: return "Idle"
        case .focus: return "Focusing"
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


// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        FooterFocusBarView()
    }
    .background(Color(red: 0.96, green: 0.96, blue: 0.94))
}