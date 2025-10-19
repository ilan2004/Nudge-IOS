// UI/Components/FooterFocusBarView.swift
import SwiftUI

struct FooterFocusBarView: View {
    @ObservedObject var viewModel: FooterFocusBarViewModel
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.mode == .idle {
                idleLayout
            } else {
                activeLayout
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .retroConsoleSurface()
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .animation(.easeInOut(duration: 0.2), value: viewModel.mode)
        .sheet(isPresented: $showSettings) {
            // Reference existing FocusSettingsView, don't redeclare
            // FocusSettingsView()
            Text("Settings") // Placeholder - use your existing FocusSettingsView
        }
    }
    
    // MARK: - Idle Layout
    private var idleLayout: some View {
        VStack(spacing: 12) {
            // Top row: Presets
            HStack(spacing: 8) {
                ForEach([25, 45, 60], id: \.self) { minutes in
                    Button("\(minutes)") {
                        viewModel.setPreset(minutes)
                    }
                    .buttonStyle(NavPillStyle(
                        variant: viewModel.selectedPreset == minutes ? .cyan : .outline,
                        compact: true
                    ))
                }
                
                Spacer()
                
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                }
                .buttonStyle(NavPillStyle(variant: .outline, compact: true))
            }
            
            // Middle row: Time adjustment
            HStack(spacing: 12) {
                Button {
                    viewModel.customMinutes = max(1, viewModel.customMinutes - 5)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(NavPillStyle(variant: .outline, compact: false))
                
                Text("\(formatHoursMinutes(viewModel.customMinutes))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.nudgeGreen900)
                    .frame(minWidth: 80)
                
                Button {
                    viewModel.customMinutes = min(240, viewModel.customMinutes + 5)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(NavPillStyle(variant: .outline, compact: false))
            }
            
            // Bottom row: Start button
            Button {
                viewModel.start()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Timer")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            .buttonStyle(NavPillStyle(variant: .primary))
        }
    }
    
    // MARK: - Active Layout
    private var activeLayout: some View {
        VStack(spacing: 12) {
            // Top row: Status and countdown
            HStack(spacing: 12) {
                // Status chip
                Text(statusLabel)
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(statusChipColor.opacity(0.3))
                    )
                    .foregroundColor(Color.nudgeGreen900)
                
                Spacer()
                
                // Countdown timer
                Text(formatMMSS(viewModel.remainingMs))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.nudgeGreen900)
                
                Spacer()
                
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                }
                .buttonStyle(NavPillStyle(variant: .outline, compact: true))
            }
            
            // Bottom row: Action buttons
            HStack(spacing: 8) {
                switch viewModel.mode {
                case .focus:
                    Button {
                        viewModel.pause()
                    } label: {
                        HStack {
                            Image(systemName: "pause.fill")
                            Text("Pause")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(NavPillStyle(variant: .amber))
                    
                    Button {
                        viewModel.startBreak(minutes: 5)
                    } label: {
                        HStack {
                            Image(systemName: "cup.and.saucer.fill")
                            Text("Break")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(NavPillStyle(variant: .cyan))
                    
                case .paused:
                    Button {
                        viewModel.resume()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Resume")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(NavPillStyle(variant: .primary))
                    
                    Button {
                        viewModel.stop()
                    } label: {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Stop")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(NavPillStyle(variant: .accent))
                    
                case .breakTime:
                    Button {
                        viewModel.stop()
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("End Break")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(NavPillStyle(variant: .cyan))
                    
                case .idle:
                    EmptyView()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private var statusLabel: String {
        switch viewModel.mode {
        case .idle: return "Idle"
        case .focus: return "Focusing"
        case .paused: return "Paused"
        case .breakTime: return "Break Time"
        }
    }
    
    private var statusChipColor: Color {
        switch viewModel.mode {
        case .idle: return .gray
        case .focus: return Color(red: 0.24, green: 0.84, blue: 0.91)
        case .paused: return Color(red: 0.96, green: 0.69, blue: 0.13)
        case .breakTime: return Color(red: 0.24, green: 0.84, blue: 0.91)
        }
    }
    
    private func formatHoursMinutes(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(mins)m"
            }
        } else {
            return "\(minutes)m"
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
    // Use actual ViewModel from Core/Services
    let vm = FooterFocusBarViewModel()
    
    return VStack {
        Spacer()
        FooterFocusBarView(viewModel: vm)
    }
    .background(Color(red: 0.96, green: 0.96, blue: 0.94))
}