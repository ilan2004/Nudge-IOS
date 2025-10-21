// UI/Components/FooterFocusBarView.swift
import SwiftUI

struct FooterFocusBarView: View {
    @ObservedObject var viewModel: FooterFocusBarViewModel
    @State private var showSettings = false
    @StateObject private var restrictions = RestrictionsController()
    @State private var blinkColon = true

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
        .sheet(isPresented: $showSettings) {
            FocusSettingsView(restrictions: restrictions)
        }
    }
    
    // MARK: - Idle Layout
    private var idleLayout: some View {
        VStack(spacing: 8) {
            // Controls row: Blocked Apps (left), Timer (center), Arrows (right)
            HStack(spacing: 12) {
                blockedAppsButton

                Spacer()

                timerSquare(ms: viewModel.customMinutes * 60_000)
                    .frame(width: 160, height: 84)
                
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
                    .frame(width: 160, height: 84)
                
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
            VStack(spacing: 6) {
                Text("Blocked")
                    .font(.system(size: 12, weight: .semibold))
                
                #if canImport(FamilyControls) && canImport(ManagedSettings)
                HStack(spacing: 6) {
                    Capsule()
                        .fill(Color.white.opacity(0.9))
                        .overlay(
                            Capsule().stroke(Color.nudgeGreen900.opacity(0.3), lineWidth: 1)
                        )
                        .frame(height: 20)
                        .overlay(
                            Text("Apps \(restrictions.selection.applicationTokens.count)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color.nudgeGreen900)
                                .padding(.horizontal, 8)
                        )
                    Capsule()
                        .fill(Color.white.opacity(0.9))
                        .overlay(
                            Capsule().stroke(Color.nudgeGreen900.opacity(0.3), lineWidth: 1)
                        )
                        .frame(height: 20)
                        .overlay(
                            Text("Web \(restrictions.selection.webDomainTokens.count)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color.nudgeGreen900)
                                .padding(.horizontal, 8)
                        )
                }
                #else
                Text("Apps 0 • Web 0")
                    .font(.system(size: 10, weight: .semibold))
                #endif
            }
            .multilineTextAlignment(.center)
            .foregroundColor(Color.nudgeGreen900)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
        }
        .frame(width: 120, height: 80)
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
        let total = max(0, ms / 1000)
        let m = total / 60
        let s = total % 60
        let mm = String(format: "%02d", m)
        let ss = String(format: "%02d", s)
        
        return ZStack {
            // Retro-styled rectangular clock face matching console theme
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.95))
                // Outer bold stroke
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.nudgeGreen900, lineWidth: 8)
                )
                // Inner subtle stroke for depth
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .inset(by: 6)
                        .stroke(Color.nudgeGreen900.opacity(0.2), lineWidth: 2)
                )
                // Top highlight to hint glossy plastic
                .overlay(
                    LinearGradient(colors: [Color.white.opacity(0.35), .clear],
                                   startPoint: .top, endPoint: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                )
                // Reuse retro console shadows for cohesion
                .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
            
            // Flip-clock style divider
            Rectangle()
                .fill(Color.nudgeGreen900.opacity(0.08))
                .frame(height: 1)
            
            // Time with blinking colon
            HStack(spacing: 4) {
                Text(mm)
                Text(":").opacity(blinkColon ? 1 : 0.2)
                Text(ss)
            }
            .font(.custom("Nippo-Regular", size: 32))
            .kerning(-0.5)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
            .foregroundColor(Color.nudgeGreen900)
            .monospacedDigit()
            .padding(.horizontal, 16)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                blinkColon.toggle()
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
    let vm = FooterFocusBarViewModel()
    
    return VStack {
        Spacer()
        FooterFocusBarView(viewModel: vm)
    }
    .background(Color(red: 0.96, green: 0.96, blue: 0.94))
}
