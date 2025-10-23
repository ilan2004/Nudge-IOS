import SwiftUI

// MARK: - Profile View
public struct ProfileView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @EnvironmentObject var focusManager: FocusManager
    @EnvironmentObject var economy: EconomyService
    @EnvironmentObject var appSettings: AppSettings

    @State private var showHistory = false
    
    // Constrain overall content width to avoid overly wide cards
    private let maxContentWidth: CGFloat = 440
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Main unified container
                VStack(spacing: 20) {
                    // Identity header
                    identityHeader
                    
                    // Separator
                    let lineBrown = Color(red: 0.45, green: 0.38, blue: 0.30)
                    Rectangle()
                        .fill(lineBrown)
                        .frame(height: 1.5)
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                                .foregroundStyle(lineBrown)
                        )
                        .padding(.horizontal, 8)
                    
                    // Focus economy (Points + Coins)
                    FocusEconomyCard(points: economy.totalFocusPoints, coins: economy.totalFocusCoins) {
                        showHistory = true
                    }
                    
                    // Separator
                    Rectangle()
                        .fill(lineBrown)
                        .frame(height: 1.5)
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                                .foregroundStyle(lineBrown)
                        )
                        .padding(.horizontal, 8)
                    
                    // Core stats
                    StatsGrid(
                        totalFocusSeconds: focusManager.totalFocusTime,
                        streakDays: focusManager.currentStreak,
                        weekly: [24, 36, 12, 48, 30, 60, 15],
                        distractionsBlocked: 0
                    )
                    
                    // Separator
                    Rectangle()
                        .fill(lineBrown)
                        .frame(height: 1.5)
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                                .foregroundStyle(lineBrown)
                        )
                        .padding(.horizontal, 8)
                    
                    // Achievements strip (placeholder)
                    AchievementStrip(items: [
                        .init(title: "Flow Unlocked", unlocked: true),
                        .init(title: "7-day Streak", unlocked: false),
                        .init(title: "1000 FP", unlocked: false)
                    ])
                    
                    // Underground Mode toggle (kept as dark nested container)
                    UndergroundToggleCard(isOn: $appSettings.undergroundMode)
                        .undergroundModeSurface()
                    
                    // Separator
                    Rectangle()
                        .fill(lineBrown)
                        .frame(height: 1.5)
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                                .foregroundStyle(lineBrown)
                        )
                        .padding(.horizontal, 8)
                    
                    // Settings list
                    SettingsList(
                        onRetakeMBTI: { personalityManager.resetPersonalityData() },
                        onNotifications: { /* TODO */ },
                        onPrivacy: { /* TODO */ },
                        onAbout: { /* TODO */ }
                    )
                }
                .padding()
                .heroCardSurface()
.overlay(alignment: .topTrailing) {
                    // Hide level seal when level is 1
                    if currentLevel > 1 {
                        let darkBrown = Color(red: 0.25, green: 0.20, blue: 0.15)
                        let stampBg = Color(red: 0.85, green: 0.75, blue: 0.60)
                        let textBrown = Color(red: 0.20, green: 0.15, blue: 0.12)
                        ZStack {
                            Circle()
                                .fill(stampBg)
                                .frame(width: 50, height: 50)
                            Circle()
                                .stroke(darkBrown, lineWidth: 2)
                                .frame(width: 50, height: 50)
                            VStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color(red: 0.60, green: 0.45, blue: 0.25))
                                    .font(.caption)
                                Text("Lv \(currentLevel)")
                                    .font(.custom("Tanker-Regular", size: 11))
                                    .foregroundColor(textBrown)
                            }
                        }
                        .padding(12)
                    }
                }
                
                Spacer(minLength: 12)
            }
            .frame(maxWidth: maxContentWidth, alignment: .center)
            .padding(.horizontal, 12)
.padding(.top, 14)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showHistory) {
            FocusEconomyHistoryView()
                .environmentObject(economy)
        }
    }
    
    // MARK: - Identity header
    private var identityHeader: some View {
        let textBrown = Color(red: 0.20, green: 0.15, blue: 0.12)
        let lineBrown = Color(red: 0.45, green: 0.38, blue: 0.30)
        return VStack(spacing: 12) {
            if let type = personalityManager.personalityType {
                HStack(alignment: .center, spacing: 16) {
                    // Character card on the left
                    CharacterCard(title: nil, size: 110, compact: true)
                        .environmentObject(personalityManager)
                        .environmentObject(focusManager)
                        .frame(width: 130, alignment: .leading)
                    // Name + personality on the right
                    VStack(alignment: .leading, spacing: 8) {
                        Text(displayName)
                            .font(.custom("Tanker-Regular", size: 24))
                            .foregroundColor(textBrown)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        PersonalityBadge(personalityType: type, gender: personalityManager.gender, guildCardStyle: true)
                        
                        Text(type.displayName)
                            .foregroundColor(textBrown)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                HStack(alignment: .center, spacing: 16) {
                    CharacterPlaceholder(size: 110)
                        .frame(width: 130, alignment: .leading)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Complete your profile")
                            .font(.headline)
                            .foregroundColor(textBrown)
                        Button("Take MBTI Test") { /* TODO */ }
                            .buttonStyle(NavPillStyle(variant: .primary))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            // Dotted separator
            Rectangle()
                .fill(lineBrown)
                .frame(height: 1.5)
                .overlay(
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                        .foregroundStyle(lineBrown)
                )
                .padding(.horizontal, 8)
        }
    }
    
    private var currentLevel: Int {
        let hours = focusManager.totalFocusTime / 3600.0
        return max(1, Int(hours / 10.0) + 1)
    }
    
    // Display name sourced from UserDefaults for now
    private var displayName: String {
        UserDefaults.standard.string(forKey: "ms_display_name") ?? "Alex"
    }
}

// MARK: - FocusEconomyCard
struct FocusEconomyCard: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    let points: Int
    let coins: Int
    let onHistory: () -> Void
    @State private var glow = false
    
    var body: some View {
        let theme = personalityManager.currentTheme
        return ZStack {
            // Vault door garnish
            Circle()
                .strokeBorder(LinearGradient(colors: [Color.gray.opacity(0.4), Color.white.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 5)
                .frame(width: 90, height: 90)
                .offset(x: 70, y: -8)
                .blur(radius: 0.2)
                .opacity(0.35)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.circle.fill")
                        .foregroundColor(theme.secondary)
                        .shadow(color: theme.secondary.opacity(0.4), radius: 6)
                    Text("Focus Economy")
                        .font(.custom("Tanker-Regular", size: 22))
                        .foregroundColor(theme.text)
                }
                
                HStack(spacing: 12) {
                    pointsBox
                    coinsBox
                }
                
                HStack {
                    Button("History", action: onHistory)
                        .buttonStyle(NavPillStyle(variant: .outline, compact: true))
                    Spacer()
                }
            }
            .padding()
            
            // Subtle particle sparkles near currency
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill((i % 2 == 0 ? Color.yellow : Color.orange).opacity(0.3))
                        .frame(width: CGFloat(3 + (i % 3)), height: CGFloat(3 + (i % 3)))
                        .scaleEffect(glow ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true).delay(Double(i) * 0.1), value: glow)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(12)
            .allowsHitTesting(false)
        }
        .onAppear { glow = true }
    }
    
    private var pointsBox: some View {
        let theme = personalityManager.currentTheme
        return VStack(alignment: .center, spacing: 8) {
            Text("\(points)")
                .font(.custom("Tanker-Regular", size: 32))
                .foregroundColor(theme.text)
            Text("Focus Points")
                .font(.custom("Tanker-Regular", size: 16))
                .foregroundColor(theme.text)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .overlay(alignment: .topTrailing) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .shadow(color: Color.yellow.opacity(0.6), radius: 8)
                .padding(8)
        }
        .statsPanelSurface()
    }
    
    private var coinsBox: some View {
        let theme = personalityManager.currentTheme
        return VStack(alignment: .center, spacing: 8) {
            Text("\(coins)")
                .font(.custom("Tanker-Regular", size: 32))
                .foregroundColor(theme.text)
            Image("focus coin (1)", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .blur(radius: 3)
            Text("Focus Coins")
                .font(.custom("Tanker-Regular", size: 16))
                .foregroundColor(theme.text)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .statsPanelSurface()
    }
}

// MARK: - StatsGrid
struct StatsGrid: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    let totalFocusSeconds: TimeInterval
    let streakDays: Int
    let weekly: [Int] // minutes per day
    let distractionsBlocked: Int
    
    private var totalHours: Double { totalFocusSeconds / 3600.0 }
    private var totalHoursText: String { String(format: "%.1f h", totalHours) }
    
    var body: some View {
        let theme = personalityManager.currentTheme
        return VStack(alignment: .leading, spacing: 12) {
            Text("Your Stats")
                .font(.custom("Tanker-Regular", size: 18))
                .foregroundColor(theme.text)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                rpgStatTile(icon: "clock.fill", title: "Total Focus", value: totalHoursText, progress: min(1.0, totalHours/50.0), tint: theme.primary)
                weeklyBarsTile(title: "Weekly Trend", values: weekly, tint: theme.secondary)
                rpgStatTile(icon: "flame.fill", title: "Streak", value: "\(streakDays) days", progress: min(1.0, Double(streakDays)/30.0), tint: .orange)
                rpgStatTile(icon: "hand.raised.fill", title: "Blocked", value: "\(distractionsBlocked)", progress: min(1.0, Double(distractionsBlocked)/50.0), tint: .red)
            }
        }
        .padding()
    }
    
    private func rpgStatTile(icon: String, title: String, value: String, progress: Double, tint: Color) -> some View {
        let theme = personalityManager.currentTheme
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(tint)
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(theme.textSecondary)
                Spacer()
            }
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(theme.text)
            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(tint.opacity(0.15))
                    Capsule().fill(tint)
                        .frame(width: max(0, min(1, progress)) * geo.size.width)
                }
            }
            .frame(height: 8)
            
            // Decorative divider
            Rectangle()
                .fill(tint.opacity(0.15))
                .frame(height: 1)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
    }
    
    private func weeklyBarsTile(title: String, values: [Int], tint: Color) -> some View {
        let theme = personalityManager.currentTheme
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill").foregroundColor(tint)
                Text(title).font(.footnote).foregroundColor(theme.textSecondary)
            }
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(values.indices, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(tint)
                        .frame(width: 10, height: CGFloat(max(8, min(60, values[i]))))
                        .opacity(0.85)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
    }
}

// MARK: - AchievementStrip
struct AchievementStrip: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    struct Item: Identifiable { let id = UUID(); let title: String; let unlocked: Bool }
    let items: [Item]
    
    var body: some View {
        let theme = personalityManager.currentTheme
        return VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.custom("Tanker-Regular", size: 20))
                .foregroundColor(theme.text)
            
            // Display shelf metaphor
            Rectangle()
                .fill(LinearGradient(colors: [Color.brown.opacity(0.25), Color.brown.opacity(0.15)], startPoint: .top, endPoint: .bottom))
                .frame(height: 6)
                .overlay(Rectangle().fill(Color.white.opacity(0.3)).frame(height: 1), alignment: .top)
                .padding(.bottom, -2)
                .accessibilityHidden(true)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        let rarityColor: Color = item.unlocked ? .yellow : .gray
                        VStack(spacing: 8) {
                            Image(systemName: item.unlocked ? "trophy.fill" : "lock.fill")
                                .font(.title2)
                                .foregroundColor(item.unlocked ? .yellow : theme.secondary)
                                .shadow(color: item.unlocked ? Color.yellow.opacity(0.6) : .clear, radius: 8)
                            Text(item.title)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(theme.text)
                        }
                        .frame(width: 96, height: 88)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(rarityColor.opacity(item.unlocked ? 0.9 : 0.4), lineWidth: item.unlocked ? 2 : 1)
                        )
                        .overlay(
                            // Spotlight for unlocked
                            RadialGradient(colors: [Color.white.opacity(item.unlocked ? 0.35 : 0.0), .clear], center: .top, startRadius: 8, endRadius: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        )
                        .opacity(item.unlocked ? 1 : 0.7)
                        .scaleEffect(item.unlocked ? 1.0 : 0.97)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: item.unlocked)
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
    @EnvironmentObject var personalityManager: PersonalityManager
    let rank: Int
    let delta: Int // negative is up
    let isDimmed: Bool
    let onSeeAll: () -> Void
    
    var body: some View {
        let theme = personalityManager.currentTheme
        let medal = medalColor(for: rank)
        let improved = delta <= 0
        return VStack(alignment: .leading, spacing: 10) {
            Text("Leaderboard")
                .font(.custom("Tanker-Regular", size: 20))
                .foregroundColor(theme.text)
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [medal.opacity(0.9), medal.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 46, height: 46)
                        .shadow(color: medal.opacity(0.4), radius: 10)
                    Text("#\(rank)")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)
                }
                .overlay(
                    HStack(spacing: 2) {
                        Image(systemName: improved ? "arrow.up" : "arrow.down")
                        Text("\(abs(delta))")
                    }
                    .font(.caption.bold())
                    .padding(6)
                    .background(Capsule().fill((improved ? Color.green : Color.red).opacity(0.15)))
                    .foregroundColor(improved ? .green : .red)
                    .offset(y: 32)
                    , alignment: .bottom
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(rankLabel(for: rank))
                        .font(.headline.weight(.semibold))
                        .foregroundColor(theme.text)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundColor(medal).opacity(rank <= 3 ? 1 : 0.6)
                        Image(systemName: "star.fill").foregroundColor(medal).opacity(rank <= 10 ? 0.8 : 0.4)
                    }
                }
                Spacer()
                Button("See All") { onSeeAll() }
                    .buttonStyle(NavPillStyle(variant: .outline, compact: true))
            }
        }
        .padding()
        .opacity(isDimmed ? 0.4 : 1.0)
        .scaleEffect(improved ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.6), value: improved)
        .overlay(alignment: .bottomLeading) {
            if isDimmed {
                Text("Underground Mode active — hidden from others")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding([.horizontal, .bottom], 12)
            }
        }
    }
    
    private func medalColor(for rank: Int) -> Color {
        switch rank {
        case 1...3: return .yellow
        case 4...10: return .gray
        default: return personalityManager.currentTheme.secondary
        }
    }
    private func rankLabel(for rank: Int) -> String {
        switch rank {
        case 1: return "Champion"
        case 2...3: return "Top 3"
        case 4...10: return "Top 10"
        default: return "Contender"
        }
    }
}

// MARK: - UndergroundToggleCard
struct UndergroundToggleCard: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @Binding var isOn: Bool
    @State private var blink = false
    var body: some View {
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: isOn ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(Color.white.opacity(0.9))
                Text("Underground Mode")
                    .font(.custom("Tanker-Regular", size: 20))
                    .foregroundColor(.white)
                Spacer()
                // status lights
                HStack(spacing: 6) {
                    Circle()
                        .fill((isOn ? Color.purple : Color.gray).opacity(blink ? 0.3 : 0.9))
                        .frame(width: 8, height: 8)
                        .shadow(color: Color.purple.opacity(isOn ? 0.6 : 0.0), radius: 6)
                    Circle()
                        .fill((isOn ? Color.blue : Color.gray).opacity(blink ? 0.9 : 0.3))
                        .frame(width: 8, height: 8)
                        .shadow(color: Color.blue.opacity(isOn ? 0.6 : 0.0), radius: 6)
                }
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: blink)
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(.purple)
            }
            Text("Stealth Mode: Train in the shadows")
                .font(.footnote)
                .foregroundColor(Color.white.opacity(0.85))
        }
        .padding()
        .onAppear { blink = true }
    }
}

// MARK: - BlockedAppsRow
struct BlockedAppsRow: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    let apps: [String]
    let onManage: () -> Void
    
    var body: some View {
        let theme = personalityManager.currentTheme
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.fill").foregroundColor(theme.secondary)
                    Text("Blocked Apps")
                        .font(.custom("Tanker-Regular", size: 20))
                        .foregroundColor(theme.text)
                }
                HStack(spacing: 8) {
                    ForEach(apps.prefix(3), id: \.self) { name in
                        HStack(spacing: 6) {
                            Text(name.capitalized)
                                .font(.caption)
                                .foregroundColor(theme.text)
                            Image(systemName: "xmark.shield.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
.padding(.horizontal, 8).padding(.vertical, 6)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red.opacity(0.3), lineWidth: 1))
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
    @EnvironmentObject var personalityManager: PersonalityManager
    let onRetakeMBTI: () -> Void
    let onNotifications: () -> Void
    let onPrivacy: () -> Void
    let onAbout: () -> Void
    
    var body: some View {
        let theme = personalityManager.currentTheme
        return VStack(spacing: 0) {
            SettingsRow(title: "Retake Personality Test", icon: "person.fill", theme: theme, action: onRetakeMBTI)
            Divider().opacity(0.15)
            SettingsRow(title: "Notifications", icon: "bell.fill", theme: theme, action: onNotifications)
            Divider().opacity(0.15)
            SettingsRow(title: "Data & Privacy", icon: "lock.fill", theme: theme, action: onPrivacy)
            Divider().opacity(0.15)
            SettingsRow(title: "About", icon: "info.circle.fill", theme: theme, action: onAbout)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}

public struct SettingsRow: View {
    let title: String
    let icon: String
    let theme: PersonalityColors
    let action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(theme.primary.opacity(0.25))
                    Image(systemName: icon)
                        .foregroundColor(theme.secondary)
                }
                .frame(width: 28, height: 28)
                
                Text(title)
                    .foregroundColor(theme.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            Rectangle().fill(Color.clear)
                .overlay(
                    Rectangle().fill(Color.white.opacity(0.001)) // better tap target
                )
        )
    }
}

#Preview {
    ProfileView()
        .environmentObject(PersonalityManager())
        .environmentObject(FocusManager())
        .environmentObject(EconomyService())
        .environmentObject(AppSettings())
}
