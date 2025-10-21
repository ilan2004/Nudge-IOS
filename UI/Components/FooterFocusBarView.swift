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
        hybridLayout(ms: viewModel.customMinutes * 60_000)
    }
    
// MARK: - Active Layout
var activeLayout: some View {
        hybridLayout(ms: viewModel.remainingMs)
    }

// MARK: - Hybrid Layout (modern + subtle retro accents)
    func hybridLayout(ms: Int) -> some View {
        VStack(spacing: 10) {
            GeometryReader { geo in
                let gap: CGFloat = 12
                let rowH: CGFloat = 130
                let colW = (geo.size.width - gap * 2) / 3

                HStack(spacing: gap) {
                    // Left: blocked apps card
                    blockedAppsButton
                        .frame(width: colW, height: rowH)

                    // Center: status chip + timer "screen"
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
                            )

                        timerSquare(ms: ms)
                            .frame(maxWidth: .infinity)
                            .frame(height: rowH - 36)
                            .overlay(
                                LinearGradient(gradient: Gradient(stops: [
                                    .init(color: Color.black.opacity(0.06), location: 0.0),
                                    .init(color: .clear, location: 0.02),
                                    .init(color: .clear, location: 0.98),
                                    .init(color: Color.black.opacity(0.06), location: 1.0),
                                ]), startPoint: .top, endPoint: .bottom)
                                .blendMode(.multiply)
                                .opacity(0.35)
                            )
                    }
                    .frame(width: colW, height: rowH, alignment: .top)

                    // Right: vertical stepper (no literal D‑pad)
                    VStack {
                        Button {
                            #if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            #endif
                            viewModel.customMinutes = min(240, viewModel.customMinutes + 5)
                        } label: {
                            Text("▲")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(Color.nudgeGreen900)
                                .frame(width: 52, height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(red: 253/255, green: 192/255, blue: 104/255))
                                        .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                                        .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.nudgeGreen900, lineWidth: 2)
                                )
                        }
                        Spacer()
                        Button {
                            #if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            #endif
                            viewModel.customMinutes = max(1, viewModel.customMinutes - 5)
                        } label: {
                            Text("▼")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(Color.nudgeGreen900)
                                .frame(width: 52, height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87)))
                                        .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                                        .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.nudgeGreen900, lineWidth: 2)
                                )
                        }
                    }
                    .frame(width: colW, height: rowH)
                }
            }
            .frame(height: 130)

            // Bottom actions row, UX-first
            Group {
                switch viewModel.mode {
                case .idle:
                    Button {
                        viewModel.start()
                    } label: {
                        HStack { Image(systemName: "play.fill"); Text("Start Session") }
                            .font(.callout.bold())
                            .foregroundColor(Color.nudgeGreen900)
                            .frame(height: 42)
                            .frame(maxWidth: 280)
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

                case .focus:
                    HStack(spacing: 8) {
                        Button { viewModel.startBreak(minutes: 5) } label: { HStack { Image(systemName: "cup.and.saucer.fill"); Text("Break") }.frame(maxWidth: .infinity) }
                            .buttonStyle(NavPillStyle(variant: .cyan))
                        Button { viewModel.stop() } label: { HStack { Image(systemName: "stop.fill"); Text("Stop") }.frame(maxWidth: .infinity) }
                            .buttonStyle(NavPillStyle(variant: .accent))
                    }
                case .paused:
                    HStack(spacing: 8) {
                        Button { viewModel.resume() } label: { HStack { Image(systemName: "play.fill"); Text("Resume") }.frame(maxWidth: .infinity) }
                            .buttonStyle(NavPillStyle(variant: .primary))
                        Button { viewModel.stop() } label: { HStack { Image(systemName: "stop.fill"); Text("Stop") }.frame(maxWidth: .infinity) }
                            .buttonStyle(NavPillStyle(variant: .accent))
                    }
                case .breakTime:
                    Button { viewModel.stop() } label: { HStack { Image(systemName: "xmark.circle.fill"); Text("End Break") }.frame(maxWidth: .infinity) }
                        .buttonStyle(NavPillStyle(variant: .cyan))
                }
            }
        }
    }

// MARK: - Full Retro Layout and Controls
    func fullRetroLayout(ms: Int) -> some View {
        VStack(spacing: 10) {
            // Top console label
            Text("NUDGE BOY")
                .font(.system(size: 11, weight: .black))
                .kerning(2)
                .foregroundColor(Color.nudgeGreen900.opacity(0.9))
                .padding(.top, 2)

            GeometryReader { geo in
                let gap: CGFloat = 12
                let rowH: CGFloat = 140
                let colW = (geo.size.width - gap * 2) / 3

                HStack(spacing: gap) {
                    // Left: D‑pad
                    dpad
                        .frame(width: colW, height: rowH)

                    // Center: status chip + screen
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
                            )

                        timerSquare(ms: ms)
                            .frame(maxWidth: .infinity)
                            .frame(height: rowH - 36)
                            .overlay(
                                LinearGradient(gradient: Gradient(stops: [
                                    .init(color: Color.black.opacity(0.08), location: 0.0),
                                    .init(color: .clear, location: 0.02),
                                    .init(color: .clear, location: 0.98),
                                    .init(color: Color.black.opacity(0.08), location: 1.0),
                                ]), startPoint: .top, endPoint: .bottom)
                                .blendMode(.multiply)
                                .opacity(0.5)
                            )
                    }
                    .frame(width: colW, height: rowH, alignment: .top)

                    // Right: A/B cluster + speaker grille
                    VStack {
                        abCluster
                        Spacer()
                        speakerGrill
                    }
                    .frame(width: colW, height: rowH)
                }
            }
            .frame(height: 140)

            // SELECT / START row
            HStack(spacing: 12) {
                thinPill(title: "SELECT") {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    showSettings = true
                }
                thinPill(title: primaryActionTitle) {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    primaryAction()
                }
            }
            .padding(.bottom, 2)
        }
        .overlay(screwsOverlay)
    }

    // MARK: D‑pad
    @ViewBuilder var dpad: some View {
        let btnSize: CGFloat = 44
        let padColor = Color("NudgeSurface", bundle: .main, default: Color(red: 0.98, green: 0.97, blue: 0.96))
        ZStack {
            // cross base
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(padColor)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.nudgeGreen900, lineWidth: 2))
                .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                .shadow(color: Color.nudgeGreen900.opacity(0.15), radius: 10, x: 0, y: 8)

            // directions
            VStack(spacing: 8) {
                Button { incMinutes(5) } label: { chevronButton(system: "chevron.up", size: btnSize, fill: Color(red: 253/255, green: 192/255, blue: 104/255)) }
                HStack(spacing: 8) {
                    Button { incMinutes(1) } label: { chevronButton(system: "chevron.left", size: btnSize, fill: Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87))) }
                    RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.6)).frame(width: 18, height: 18).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.nudgeGreen900.opacity(0.3), lineWidth: 1))
                    Button { incMinutes(-1) } label: { chevronButton(system: "chevron.right", size: btnSize, fill: Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87))) }
                }
                Button { incMinutes(-5) } label: { chevronButton(system: "chevron.down", size: btnSize, fill: Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87))) }
            }
            .padding(10)
        }
    }

    func incMinutes(_ delta: Int) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        let next = max(1, min(240, viewModel.customMinutes + delta))
        viewModel.customMinutes = next
    }

    func chevronButton(system: String, size: CGFloat, fill: Color) -> some View {
        Image(systemName: system)
            .font(.system(size: 18, weight: .black))
            .foregroundColor(Color.nudgeGreen900)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(fill)
                    .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                    .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.nudgeGreen900, lineWidth: 2)
            )
    }

    // MARK: A/B cluster
    @ViewBuilder var abCluster: some View {
        let aColor = Color(red: 253/255, green: 192/255, blue: 104/255)
        let bColor = Color("NudgeCyanSurface", bundle: .main, default: Color(red: 0.81, green: 0.98, blue: 1.0))
        VStack(spacing: 6) {
            HStack(spacing: 14) {
                Button { secondaryAction() } label: {
                    Text("B")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(Color.nudgeGreen900)
                        .frame(width: 46, height: 46)
                        .background(Circle().fill(bColor)
                            .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                            .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8))
                        .overlay(Circle().stroke(Color.nudgeGreen900, lineWidth: 2))
                }
                Button { primaryAction() } label: {
                    Text("A")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(Color.nudgeGreen900)
                        .frame(width: 58, height: 58)
                        .background(Circle().fill(aColor)
                            .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                            .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8))
                        .overlay(Circle().stroke(Color.nudgeGreen900, lineWidth: 3))
                }
                .offset(y: -6)
            }
            HStack(spacing: 24) {
                Text(secondaryActionTitle).font(.system(size: 10, weight: .semibold)).foregroundColor(Color.nudgeGreen900.opacity(0.8))
                Text(primaryActionTitle).font(.system(size: 10, weight: .semibold)).foregroundColor(Color.nudgeGreen900.opacity(0.8))
            }
            .padding(.top, 2)
        }
    }

    var primaryActionTitle: String {
        switch viewModel.mode {
        case .idle: return "Start"
        case .focus: return "Break"
        case .paused: return "Resume"
        case .breakTime: return "End"
        }
    }
    var secondaryActionTitle: String {
        switch viewModel.mode {
        case .idle: return "Settings"
        case .focus: return "Stop"
        case .paused: return "Stop"
        case .breakTime: return "Settings"
        }
    }

    func primaryAction() {
        switch viewModel.mode {
        case .idle:
            viewModel.start()
        case .focus:
            viewModel.startBreak(minutes: 5)
        case .paused:
            viewModel.resume()
        case .breakTime:
            viewModel.stop()
        }
    }
    func secondaryAction() {
        switch viewModel.mode {
        case .idle:
            showSettings = true
        case .focus:
            viewModel.stop()
        case .paused:
            viewModel.stop()
        case .breakTime:
            showSettings = true
        }
    }

    // MARK: SELECT/START thin pills
    func thinPill(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color.nudgeGreen900)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color("NudgeGreenSurface", bundle: .main, default: Color(red: 0.83, green: 0.96, blue: 0.87)))
                        .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 3)
                        .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 10, x: 0, y: 6)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.nudgeGreen900, lineWidth: 2)
                )
        }
    }

    // MARK: Speaker grill
    @ViewBuilder var speakerGrill: some View {
        HStack(spacing: 6) {
            ForEach(0..<6, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.nudgeGreen900.opacity(0.25))
                    .frame(width: 4, height: 28)
            }
        }
        .padding(.trailing, 8)
    }

    // MARK: Screws overlay
    @ViewBuilder var screwsOverlay: some View {
        GeometryReader { geo in
            let s: CGFloat = 6
            ZStack {
                Circle().fill(Color.nudgeGreen900.opacity(0.35)).frame(width: s, height: s).position(x: 10, y: 10)
                Circle().fill(Color.nudgeGreen900.opacity(0.35)).frame(width: s, height: s).position(x: geo.size.width - 10, y: 10)
                Circle().fill(Color.nudgeGreen900.opacity(0.35)).frame(width: s, height: s).position(x: 10, y: geo.size.height - 10)
                Circle().fill(Color.nudgeGreen900.opacity(0.35)).frame(width: s, height: s).position(x: geo.size.width - 10, y: geo.size.height - 10)
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
                        .foregroundColor(Color.nudgeGreen900)
                        .padding(.horizontal, 8)
                } else {
                    // Show only icons for selected items (apps first, then web)
                    let showCore = min(3, totalSel)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(0..<showCore, id: \.self) { idx in
                            let isApp = idx < appsCount
                            Circle()
                                .fill(Color.white)
                                .overlay(Circle().stroke(Color.nudgeGreen900.opacity(0.25), lineWidth: 1))
.frame(width: 22, height: 22)
                                .overlay(
                                    Image(systemName: isApp ? "app.fill" : "globe")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.nudgeGreen900)
                                )
                        }
                        if totalSel > showCore {
                            Circle()
                                .fill(Color.white)
                                .overlay(Circle().stroke(Color.nudgeGreen900.opacity(0.25), lineWidth: 1))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text("+\(totalSel - showCore)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Color.nudgeGreen900)
                                )
                        }
                    }
                    .padding(.horizontal, 4)
                }
                #else
                Text("Select apps to block")
                    .font(.system(size: 11, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.nudgeGreen900)
                    .padding(.horizontal, 8)
                #endif
            }
            .foregroundColor(Color.nudgeGreen900)
.frame(width: 88, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 174/255, green: 251/255, blue: 255/255))
                    .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                    .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.nudgeGreen900, lineWidth: 2)
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
