import SwiftUI

// MARK: - Profile View
public struct ProfileView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @EnvironmentObject var focusManager: FocusManager
    @EnvironmentObject var economy: EconomyService
    @EnvironmentObject var appSettings: AppSettings

    @State private var showHistory = false
    @State private var showManageBlocking = false
    @State private var showLeaderboard = false
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Identity header
                identityHeader
                    .retroConsoleSurface()
                
                // Focus economy (Points + Coins)
                FocusEconomyCard(points: economy.totalFocusPoints, coins: economy.totalFocusCoins) {
                    showHistory = true
                }
                .retroConsoleSurface()
                
                // Core stats
                StatsGrid(
                    totalFocusSeconds: focusManager.totalFocusTime,
                    streakDays: focusManager.currentStreak,
                    weekly: [24, 36, 12, 48, 30, 60, 15],
                    distractionsBlocked: 0
                )
                .retroConsoleSurface()
                
                // Achievements strip (placeholder)
                AchievementStrip(items: [
                    .init(title: "Flow Unlocked", unlocked: true),
                    .init(title: "7-day Streak", unlocked: false),
                    .init(title: "1000 FP", unlocked: false)
                ])
                .retroConsoleSurface()
                
                // Social snapshot
                LeaderboardTile(rank: 12, delta: -2, isDimmed: appSettings.undergroundMode, onSeeAll: { showLeaderboard = true })
                    .retroConsoleSurface()
                
                // Underground Mode toggle
                UndergroundToggleCard(isOn: $appSettings.undergroundMode)
                    .retroConsoleSurface()
                
                // Smart Blocking summary
                BlockedAppsRow(apps: ["instagram", "youtube", "tiktok"]) {
                    showManageBlocking = true
                }
                .retroConsoleSurface()
                
                // Settings list
                SettingsList(
                    onRetakeMBTI: { personalityManager.resetPersonalityData() },
                    onNotifications: { /* TODO */ },
                    onPrivacy: { /* TODO */ },
                    onAbout: { /* TODO */ }
                )
                .retroConsoleSurface()
                
                Spacer(minLength: 12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .sheet(isPresented: $showHistory) {
            FocusEconomyHistoryView()
                .environmentObject(economy)
        }
.sheet(isPresented: $showManageBlocking) {
            ManageBlockingView()
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView()
                .environmentObject(personalityManager)
        }
    }
    
    // MARK: - Identity header
    private var identityHeader: some View {
        VStack(spacing: 16) {
            if let type = personalityManager.personalityType {
                CharacterCard(title: nil, size: 240)
                    .environmentObject(personalityManager)
                    .environmentObject(focusManager)
                
                PersonalityBadge(personalityType: type, gender: personalityManager.gender)
                
                Text(type.rawValue)
                    .font(.custom("Tanker-Regular", size: 20))
                    .foregroundColor(personalityManager.currentTheme.text)
            } else {
                CharacterPlaceholder(size: 200)
                Button("Take MBTI Test") { /* TODO */ }
                    .buttonStyle(NavPillStyle(variant: .primary))
            }
        }
        .padding()
    }
}

// MARK: - FocusEconomyCard
struct FocusEconomyCard: View {
    let points: Int
    let coins: Int
    let onHistory: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Focus Economy")
                .font(.custom("Tanker-Regular", size: 22))
                .foregroundColor(.nudgeGreen900)
            
            HStack(spacing: 16) {
                metric(icon: "star.fill", title: "Focus Points", value: points)
                metric(icon: "bitcoinsign.circle.fill", title: "Focus Coins", value: coins)
            }
            
            HStack {
                Button("History", action: onHistory)
                    .buttonStyle(NavPillStyle(variant: .outline, compact: true))
                Spacer()
            }
        }
        .padding()
    }
    
    private func metric(icon: String, title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.nudgeGreen900)
                Text(title)
                    .font(.footnote).foregroundColor(.secondary)
            }
            Text("\(value)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.nudgeGreen900)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.6)))
    }
}

// MARK: - StatsGrid
struct StatsGrid: View {
    let totalFocusSeconds: TimeInterval
    let streakDays: Int
    let weekly: [Int] // minutes per day
    let distractionsBlocked: Int
    
    private var totalHoursText: String {
        let hours = totalFocusSeconds / 3600.0
        return String(format: "%.1f h", hours)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Stats")
                .font(.custom("Tanker-Regular", size: 20))
                .foregroundColor(.nudgeGreen900)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statTile(icon: "clock.fill", title: "Total Focus", value: totalHoursText)
                miniBarsTile(title: "Weekly Trend", values: weekly)
                statTile(icon: "flame.fill", title: "Streak", value: "\(streakDays) days")
                statTile(icon: "hand.raised.fill", title: "Blocked", value: "\(distractionsBlocked)")
            }
        }
        .padding()
    }
    
    private func statTile(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundColor(.nudgeGreen900)
                Text(title).font(.footnote).foregroundColor(.secondary)
            }
            Text(value).font(.headline).foregroundColor(.nudgeGreen900)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.6)))
    }
    
    private func miniBarsTile(title: String, values: [Int]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.footnote).foregroundColor(.secondary)
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(values.indices, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.nudgeGreen900)
                        .frame(width: 10, height: CGFloat(max(8, min(60, values[i]))))
                        .opacity(0.85)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.6)))
    }
}

// MARK: - AchievementStrip
struct AchievementStrip: View {
    struct Item: Identifiable { let id = UUID(); let title: String; let unlocked: Bool }
    let items: [Item]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.custom("Tanker-Regular", size: 20))
                .foregroundColor(.nudgeGreen900)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        VStack(spacing: 8) {
                            Image(systemName: item.unlocked ? "rosette" : "lock.fill")
                                .font(.title2)
                                .foregroundColor(.nudgeGreen900)
                            Text(item.title)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 120, height: 100)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.6)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.nudgeGreen900.opacity(item.unlocked ? 1 : 0.2), lineWidth: 2)
                        )
                        .opacity(item.unlocked ? 1 : 0.6)
                        .scaleEffect(item.unlocked ? 1.0 : 0.98)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
    }
}

// MARK: - LeaderboardTile
struct LeaderboardTile: View {
    let rank: Int
    let delta: Int // negative is up
    let isDimmed: Bool
    let onSeeAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Leaderboard")
                .font(.custom("Tanker-Regular", size: 20))
                .foregroundColor(.nudgeGreen900)
            HStack(spacing: 12) {
                Text("#\(rank)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.nudgeGreen900)
                Text(deltaText)
                    .font(.footnote)
                    .foregroundColor(delta <= 0 ? .green : .red)
                Spacer()
                Button("See Full Leaderboard") { onSeeAll() }
                    .buttonStyle(NavPillStyle(variant: .outline, compact: true))
            }
        }
        .padding()
        .opacity(isDimmed ? 0.4 : 1.0)
        .overlay(alignment: .bottomLeading) {
            if isDimmed {
                Text("Underground Mode active — hidden from others")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding([.horizontal, .bottom], 12)
            }
        }
    }
    
    private var deltaText: String {
        if delta == 0 { return "no change" }
        let arrow = delta <= 0 ? "arrow.up" : "arrow.down"
        return "\(Image(systemName: arrow)) \(abs(delta)) this week"
    }
}

// MARK: - UndergroundToggleCard
struct UndergroundToggleCard: View {
    @Binding var isOn: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Underground Mode")
                    .font(.custom("Tanker-Regular", size: 20))
                    .foregroundColor(.nudgeGreen900)
                Spacer()
                Toggle("", isOn: $isOn).labelsHidden()
            }
            Text("Private training mode: your points are hidden from public leaderboards. You still see your stats.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - BlockedAppsRow
struct BlockedAppsRow: View {
    let apps: [String]
    let onManage: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Blocked Apps")
                    .font(.custom("Tanker-Regular", size: 20))
                    .foregroundColor(.nudgeGreen900)
                HStack(spacing: 8) {
                    ForEach(apps.prefix(3), id: \.self) { name in
                        Text(name.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.6)))
                    }
                }
            }
            Spacer()
            Button("Manage", action: onManage)
                .buttonStyle(NavPillStyle(variant: .outline, compact: true))
        }
        .padding()
    }
}

// MARK: - SettingsList
struct SettingsList: View {
    let onRetakeMBTI: () -> Void
    let onNotifications: () -> Void
    let onPrivacy: () -> Void
    let onAbout: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            SettingsRow(title: "Retake Personality Test", icon: "person.fill", action: onRetakeMBTI)
            SettingsRow(title: "Notifications", icon: "bell.fill", action: onNotifications)
            SettingsRow(title: "Data & Privacy", icon: "lock.fill", action: onPrivacy)
            SettingsRow(title: "About", icon: "info.circle.fill", action: onAbout)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}

public struct SettingsRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.nudgeGreen900)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.nudgeGreen900)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(PersonalityManager())
        .environmentObject(FocusManager())
        .environmentObject(EconomyService())
        .environmentObject(AppSettings())
}
