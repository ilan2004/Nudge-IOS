// UI/Components/FooterFocusBarView.swift
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif


struct FooterFocusBarView: View {
    @ObservedObject var viewModel: FooterFocusBarViewModel
    @State var showSettings = false
    @StateObject var restrictions = RestrictionsController()
    @State var blinkColon = true

    var body: some View {
        VStack(spacing: 12) {
            if viewModel.mode == .idle {
                idleLayout
            } else {
                activeLayout
            }
        }
.padding(8)
        .retroConsoleSurface()
        .sheet(isPresented: $showSettings) {
            FocusSettingsView(restrictions: restrictions)
        }
    }
    
// MARK: - Idle Layout
var idleLayout: some View {
        VStack(spacing: 6) {
            // Controls row: Blocked Apps (left), Timer (center), Arrows (right)
            HStack(spacing: 4) {
                blockedAppsButton

                VStack(spacing: 8) {
                    Text(statusLabel.uppercased())
                        .font(.system(size: 12, weight: .black))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(Color.nudgeGreen900)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(statusChipFill)
                                .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                                .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.nudgeGreen900, lineWidth: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .inset(by: 2)
                                        .stroke(Color.nudgeGreen900.opacity(0.15), lineWidth: 1)
                                )
                                .overlay(
                                    LinearGradient(colors: [Color.white.opacity(0.25), .clear], startPoint: .top, endPoint: .center)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                )
                        )
                    timerSquare(ms: viewModel.customMinutes * 60_000)
                        .frame(width: 160, height: 72)
                        .padding(.horizontal, 6)
                }
                
                VStack(spacing: 8) {
                    
                
                    Button {
#if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
#endif
                        viewModel.customMinutes = min(240, viewModel.customMinutes + 5)
                    } label: {
                        Text("▲")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(Color.nudgeGreen900)
                            .frame(width: 56, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87)))
                                    .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                                    .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.nudgeGreen900, lineWidth: 3)
                            )
                    }

                    Button {
#if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
#endif
                        viewModel.customMinutes = max(1, viewModel.customMinutes - 5)
                    } label: {
                        Text("▼")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(Color.nudgeGreen900)
                            .frame(width: 56, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87)))
                                    .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                                    .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.nudgeGreen900, lineWidth: 3)
                            )
                    }
                }
            }
            
            // Bottom row: Start button
            Button {
                viewModel.start()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Session")
                }
                .font(.callout.bold())
                .foregroundColor(Color.nudgeGreen900)
                .frame(height: 40)
                .frame(width: 265)
                .frame(alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87)))
                        .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                        .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.nudgeGreen900, lineWidth: 2)
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
    
// MARK: - Active Layout
var activeLayout: some View {
        VStack(spacing: 6) {
            // Top row: Blocked Apps (left), Timer (center), Status (right)
            HStack(spacing: 4) {
                blockedAppsButton

                VStack(spacing: 8) {
                    Text(statusLabel.uppercased())
                        .font(.system(size: 12, weight: .black))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(Color.nudgeGreen900)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(statusChipFill)
                                .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                                .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.nudgeGreen900, lineWidth: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .inset(by: 2)
                                        .stroke(Color.nudgeGreen900.opacity(0.15), lineWidth: 1)
                                )
                                .overlay(
                                    LinearGradient(colors: [Color.white.opacity(0.25), .clear], startPoint: .top, endPoint: .center)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                )
                        )
                    timerSquare(ms: viewModel.remainingMs)
                        .frame(width: 160, height: 72)
                        .padding(.horizontal, 6)
                }
                
                VStack(spacing: 8) {
                    Button {
#if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
#endif
                        viewModel.customMinutes = min(240, viewModel.customMinutes + 5)
                    } label: {
                        Text("▲")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(Color.nudgeGreen900)
                            .frame(width: 56, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87)))
                                    .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                                    .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.nudgeGreen900, lineWidth: 3)
                            )
                    }

                    Button {
#if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
#endif
                        viewModel.customMinutes = max(1, viewModel.customMinutes - 5)
                    } label: {
                        Text("▼")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(Color.nudgeGreen900)
                            .frame(width: 56, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87)))
                                    .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                                    .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.nudgeGreen900, lineWidth: 3)
                            )
                    }
                }
            }
            
            // Bottom row: Action buttons
            HStack(spacing: 6) {
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
    var blockedAppsButton: some View {
        Button {
            showSettings = true
        } label: {
            VStack(spacing: 6) {
                Text("Blocked")
                    .font(.system(size: 12, weight: .semibold))

                #if canImport(FamilyControls) && canImport(ManagedSettings)
                let appsCount = restrictions.selection.applicationTokens.count
                let webCount = restrictions.selection.webDomainTokens.count
                let totalSel = appsCount + webCount

                if totalSel == 0 {
                    Text("Select apps to block")
                        .font(.system(size: 11, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("NudgeRed700", bundle: .main, default: Color(red: 0.75, green: 0.20, blue: 0.20)))
                        .padding(.horizontal, 8)
                } else {
                    // Show only icons for selected items (apps first, then web)
                    let showCore = min(3, totalSel)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(0..<showCore, id: \.self) { idx in
                            let isApp = idx < appsCount
                            Circle()
                                .fill(Color.white)
                                .overlay(Circle().stroke(Color("NudgeRed700", bundle: .main, default: Color(red: 0.75, green: 0.20, blue: 0.20)).opacity(0.25), lineWidth: 1))
.frame(width: 22, height: 22)
                                .overlay(
                                    Image(systemName: isApp ? "app.fill" : "globe")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color("NudgeRed700", bundle: .main, default: Color(red: 0.75, green: 0.20, blue: 0.20)))
                                )
                        }
                        if totalSel > showCore {
                            Circle()
                                .fill(Color.white)
                                .overlay(Circle().stroke(Color("NudgeRed700", bundle: .main, default: Color(red: 0.75, green: 0.20, blue: 0.20)).opacity(0.25), lineWidth: 1))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text("+\(totalSel - showCore)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Color("NudgeRed700", bundle: .main, default: Color(red: 0.75, green: 0.20, blue: 0.20)))
                                )
                        }
                    }
                    .padding(.horizontal, 4)
                }
                #else
                Text("Select apps to block")
                    .font(.system(size: 11, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("NudgeRed700", bundle: .main, default: Color(red: 0.75, green: 0.20, blue: 0.20)))
                    .padding(.horizontal, 8)
                #endif
            }
            .foregroundColor(Color("NudgeRed700", bundle: .main, default: Color(red: 0.75, green: 0.20, blue: 0.20)))
.frame(width: 88, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color("NudgeRedSurface", bundle: .main, default: Color(red: 1.0, green: 0.92, blue: 0.92)))
                    .shadow(color: Color("NudgeRed700", bundle: .main, default: Color(red: 0.75, green: 0.20, blue: 0.20)), radius: 0, x: 0, y: 4)
                    .shadow(color: Color("NudgeRed700", bundle: .main, default: Color(red: 0.75, green: 0.20, blue: 0.20)).opacity(0.2), radius: 12, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color("NudgeRed700", bundle: .main, default: Color(red: 0.75, green: 0.20, blue: 0.20)), lineWidth: 2)
            )
        }
    }
    
// MARK: - Timer Square
    func timerSquare(ms: Int) -> some View {
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
.font(.custom("Nippo-Regular", size: 28))
            .kerning(-0.5)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
            .foregroundColor(Color.nudgeGreen900)
            .monospacedDigit()
.padding(.horizontal, 12)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                blinkColon.toggle()
            }
        }
    }
    
// MARK: - Helper Methods
    var statusLabel: String {
        switch viewModel.mode {
        case .idle: return "Idle"
        case .focus: return "Focusing"
        case .paused: return "Paused"
        case .breakTime: return "Break Time"
        }
    }
    
    var statusChipColor: Color {
        switch viewModel.mode {
        case .idle: return Color.nudgeGreen900
        case .focus: return Color.nudgeGreen900
        case .paused: return Color.nudgeGreen900
        case .breakTime: return Color.nudgeGreen900
        }
    }
    
    // Retro chip fill color per state (uses surface tokens where available)
    var statusChipFill: Color {
        switch viewModel.mode {
        case .idle:
            return Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96))
        case .focus:
            return Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87))
        case .paused:
            return Color("NudgeAmberSurface", bundle: .main, default: Color(red: 1.0, green: 0.95, blue: 0.78))
        case .breakTime:
            return Color("NudgeCyanSurface", bundle: .main, default: Color(red: 0.81, green: 0.98, blue: 1.0))
        }
    }
    
    func formatHoursMinutes(_ minutes: Int) -> String {
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
    
    func formatMMSS(_ ms: Int) -> String {
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
    
    VStack {
        Spacer()
        FooterFocusBarView(viewModel: vm)
    }
    .background(Color(red: 0.96, green: 0.96, blue: 0.94))
}
