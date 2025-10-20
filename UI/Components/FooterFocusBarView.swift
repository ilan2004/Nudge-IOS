// UI/Components/FooterFocusBarView.swift
import SwiftUI

struct FooterFocusBarView: View {
    @ObservedObject var viewModel: FooterFocusBarViewModel
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 12) {
            if viewModel.mode == .idle {
                idleLayout
            } else {
                activeLayout
            }
        }
        .padding(12)
        .retroConsoleSurface()
    }
    
    // MARK: - Idle Layout
    private var idleLayout: some View {
        VStack(spacing: 8) {
            // Controls row: Blocked Apps (left), Timer (center), Arrows (right)
            HStack(spacing: 12) {
                blockedAppsButton

                Spacer()

                timerSquare(ms: viewModel.customMinutes * 60_000)
                    .frame(width: 80, height: 80)

                Spacer()

                VStack(spacing: 8) {
                    Button {
                        viewModel.customMinutes = min(240, viewModel.customMinutes + 5)
                    } label: {
                        Text("↑")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(NavPillStyle(variant: .primary, compact: true))

                    Button {
                        viewModel.customMinutes = max(1, viewModel.customMinutes - 5)
                    } label: {
                        Text("↓")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(NavPillStyle(variant: .amber, compact: true))
                }
            }
            
            // Bottom row: Start button
            Button {
                viewModel.start()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Set Timer")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
            }
            .buttonStyle(NavPillStyle(variant: .primary))
        }
    }
    
    // MARK: - Active Layout
    private var activeLayout: some View {
        VStack(spacing: 8) {
            // Top row: Blocked Apps (left), Timer (center), Status (right)
            HStack(spacing: 12) {
                blockedAppsButton

                Spacer()

                timerSquare(ms: viewModel.remainingMs)
                    .frame(width: 80, height: 80)

                Spacer()

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
            }
            
            // Bottom row: Action buttons
            HStack(spacing: 8) {
                switch viewModel.mode {
                case .focus:
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
    
    // MARK: - Blocked Apps Button
    private var blockedAppsButton: some View {
        Button {
            showSettings = true
        } label: {
            VStack(spacing: 2) {
                Text("Blocked")
                Text("Apps")
            }
            .font(.system(size: 12, weight: .semibold))
            .multilineTextAlignment(.center)
            .foregroundColor(Color.nudgeGreen900)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
        }
        .frame(width: 88, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.nudgeGreen900.opacity(0.2), lineWidth: 1)
                )
        )
        .retroConsoleSurface()
    }
    
    // MARK: - Timer Square
    private func timerSquare(ms: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.nudgeGreen900.opacity(0.2), lineWidth: 1)
                )
                .retroConsoleSurface()
            
            VStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.nudgeGreen900)
                Text(formatMMSS(ms))
                    .font(.custom("Nippo-Regular", size: 22))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundColor(Color.nudgeGreen900)
                    .monospacedDigit()
            }
            .padding(8)
        }
        .aspectRatio(1, contentMode: .fit)
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
    let vm = FooterFocusBarViewModel()
    
    return VStack {
        Spacer()
        FooterFocusBarView(viewModel: vm)
    }
    .background(Color(red: 0.96, green: 0.96, blue: 0.94))
}
