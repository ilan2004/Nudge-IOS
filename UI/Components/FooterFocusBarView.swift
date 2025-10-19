import SwiftUI

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
            .background(Capsule().fill(Color.cyan.opacity(0.2)))
    }

    private var countdown: some View {
        Text(formatMMSS(vm.remainingMs))
            .font(.system(.footnote, design: .monospaced))
            .foregroundColor(.secondary)
    }

    private var presets: some View {
        HStack(spacing: 6) {
            ForEach([25, 45, 60], id: \.self) { m in
                Button("\\(m)m") { vm.setPreset(m) }
                    .buttonStyle(NavPillStyle(variant: vm.selectedPreset == m ? .cyan : .outline, compact: true))
            }
        }
    }

    private var customMinutes: some View {
        HStack(spacing: 4) {
            Stepper(value: $vm.customMinutes, in: 1...240, step: 1) {
                Text("\(vm.customMinutes)m")
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(minWidth: 80, maxWidth: 120) // Flexible width
        }
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

    private func formatMMSS(_ ms: Int) -> String {
        guard ms > 0 else { return "00:00" }
        let total = ms / 1000
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    FooterFocusBarView()
        .padding()
}

