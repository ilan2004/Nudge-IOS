import SwiftUI
import AVFoundation

struct CharacterCard: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @EnvironmentObject var focusManager: FocusManager
    
    let title: String?
    let size: CGFloat
    
    @State private var displayName: String = ""
    @State private var showIntro: Bool = true
    @State private var showVideoAnimation: Bool = false
    @State private var currentVideoURL: URL?
    @State private var videoNonce: Int = 0
    
    // Focus session tracking
    @State private var focusProgress: Double = 0.0
    @State private var focusMode: String = "idle"
    
    
    // Dialogue system
    @State private var greeting: String = ""
    @State private var motivation: String = ""
    
    init(title: String? = nil, size: CGFloat = 0) {
        self.title = title
        self.size = size > 0 ? size : 384 // Default size
    }
    
    private var heading: String {
        if !displayName.isEmpty {
            return displayName
        }
        return title ?? "Player"
    }
    
    // Compute a stable card size based on screen width (not GeometryReader) so it behaves inside ScrollView/VStack
    private var cardSize: CGFloat {
        if size > 0 { return size }
        let screenWidth = UIScreen.main.bounds.width
        // Use a conservative fraction and clamp to keep within viewport on all devices
        let base = floor((min(screenWidth, 600) - 32) * 0.60)
        return max(200, min(340, base))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with name and edit button
            HStack {
                OutlinedText(
                    text: heading,
                    font: .custom("Tanker-Regular", size: 40),
                    foreground: .greenPrimary,
                    outline: .defaultCream,
                    lineWidth: 3
                )
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                Button("Edit") {
                    // TODO: Show name edit modal
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
                .foregroundColor(.secondary)
            }
            
            // Main character display (reserve explicit height so following cards don't overlap)
            ZStack {
                // Focus Ring behind character (not masked)
                FocusRing(
                    size: cardSize + 12,
                    stroke: max(6, min(12, cardSize * 0.026)),
                    value: focusProgress,
                    mode: focusMode
                )
                .zIndex(0)
                
                // Character container
                ZStack {
                    if let personalityType = personalityManager.personalityType {
                        // Character image/video display
                        CharacterMediaView(
                            personalityType: personalityType,
                            gender: personalityManager.gender,
                            size: cardSize,
                            showVideoAnimation: $showVideoAnimation,
                            currentVideoURL: $currentVideoURL,
                            videoNonce: $videoNonce
                        )
                    } else {
                        // Placeholder when no personality type
                        CharacterPlaceholder(size: cardSize)
                    }
                }
                .frame(width: cardSize, height: cardSize)
                .clipShape(Circle())
                .zIndex(1)
            }
            .frame(height: cardSize + 24)
            
            // Personality Badge removed for now; keep dialogue only
            if personalityManager.personalityType != nil {
                VStack(spacing: 12) {
                    // Character Dialogue
                    VStack(spacing: 8) {
                        if !greeting.isEmpty {
                            DialogueBubble(text: greeting, style: .greeting)
                        }
                        if !motivation.isEmpty {
                            DialogueBubble(text: motivation, style: .motivation)
                        }
                    }
                }
            }
            
        }
        .onAppear {
            loadUserData()
            setupFocusTracking()
            playIntroAnimation()
        }
        .onChange(of: focusManager.currentState) {
            updateFocusDisplay()
        }
        .onChange(of: personalityManager.personalityType) { _, newType in
            if newType != nil {
                playCharacterAnimation()
                updateDialogue()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadUserData() {
        displayName = UserDefaults.standard.string(forKey: "ms_display_name") ?? "Alex" // Default name for testing
    }
    
    private func setupFocusTracking() {
        // Update focus display based on manager state
        updateFocusDisplay()
    }
    
    private func updateFocusDisplay() {
        focusProgress = focusManager.progress
        
        switch focusManager.currentState {
        case .focusing:
            focusMode = "focus"
        case .onBreak:
            focusMode = "break"
        case .paused:
            focusMode = "paused"
        default:
            focusMode = "idle"
        }
    }
    
    private func playIntroAnimation() {
        showIntro = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showIntro = false
            }
        }
    }
    
    private func playCharacterAnimation() {
        guard let personalityType = personalityManager.personalityType else { return }
        
        // Get video path for personality type and gender
        let videoName = PersonalityTheme.mediaName(for: personalityType, gender: personalityManager.gender, isVideo: true)
        
        if let videoPath = Bundle.main.path(forResource: videoName, ofType: "mp4"),
           let videoURL = URL(string: "file://\(videoPath)") {
            currentVideoURL = videoURL
            showVideoAnimation = true
            videoNonce += 1
            
            // Auto-hide after 6 seconds (safety timeout)
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showVideoAnimation = false
                }
            }
        }
    }
    
    private func updateDialogue() {
        guard let personalityType = personalityManager.personalityType else { return }
        
        // Generate personality-specific dialogue based on current state
        let hasActiveSession = focusManager.isActive
        
        // Simple dialogue system - can be expanded
        switch personalityType {
        case .enfj:
            greeting = hasActiveSession ? "Great focus! You're inspiring others." : "Ready to make a positive impact?"
            motivation = hasActiveSession ? "Keep going strong!" : "Let's achieve something meaningful together!"
            
        case .intj:
            greeting = hasActiveSession ? "Strategic thinking in progress." : "What's your master plan today?"
            motivation = hasActiveSession ? "Efficiency is key." : "Time to execute with precision."
            
        case .infp:
            greeting = hasActiveSession ? "Following your inner compass." : "What speaks to your heart today?"
            motivation = hasActiveSession ? "Stay true to yourself." : "Create something meaningful."
            
        default:
            greeting = hasActiveSession ? "You're in the zone!" : "Ready for focused work?"
            motivation = hasActiveSession ? "Keep it up!" : "Let's make progress together."
        }
    }
}

struct CharacterMediaView: View {
    let personalityType: PersonalityType
    let gender: Gender
    let size: CGFloat
    
    @Binding var showVideoAnimation: Bool
    @Binding var currentVideoURL: URL?
    @Binding var videoNonce: Int
    
    private var imageName: String {
        PersonalityTheme.mediaName(for: personalityType, gender: gender, isVideo: false)
    }
    
    var body: some View {
        ZStack {
            // Base static image from Asset Catalog
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipped()
            .opacity(showVideoAnimation ? 0 : 1)
            .animation(.easeInOut(duration: 0.5), value: showVideoAnimation)
            
            // Video overlay for animations
            if showVideoAnimation, let videoURL = currentVideoURL {
                VideoPlayerView(
                    url: videoURL,
                    isPlaying: showVideoAnimation,
                    onEnded: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showVideoAnimation = false
                        }
                    }
                )
                .frame(width: size, height: size)
                .clipped()
                .opacity(showVideoAnimation ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: showVideoAnimation)
            }
            
            // Video indicator
            if showVideoAnimation {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.red.opacity(0.8))
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: showVideoAnimation)
                            .padding()
                    }
                }
            }
        }
    }
}

struct VideoPlayerView: UIViewRepresentable {
    let url: URL
    let isPlaying: Bool
    let onEnded: () -> Void
    
    func makeUIView(context: Context) -> VideoPlayerUIView {
        let view = VideoPlayerUIView()
        view.onEnded = onEnded
        return view
    }
    
    func updateUIView(_ uiView: VideoPlayerUIView, context: Context) {
        uiView.configure(with: url)
        if isPlaying {
            uiView.play()
        } else {
            uiView.pause()
        }
    }
}

class VideoPlayerUIView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    var onEnded: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayer()
    }
    
    private func setupPlayer() {
        playerLayer = AVPlayerLayer()
        playerLayer?.videoGravity = .resizeAspectFill
        if let layer = playerLayer {
            self.layer.addSublayer(layer)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    func configure(with url: URL) {
        player = AVPlayer(url: url)
        playerLayer?.player = player
        
        // Add observer for playback end
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.onEnded?()
        }
    }
    
    func play() {
        player?.seek(to: .zero)
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

struct CharacterPlaceholder: View {
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.1))
            .frame(width: size, height: size)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: size * 0.2))
                        .foregroundColor(.gray.opacity(0.4))
                    
                    Text("Take the personality test\nto unlock your character")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            )
            .overlay(
                Circle()
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
            )
    }
}

struct DialogueBubble: View {
    let text: String
    let style: DialogueStyle
    
    enum DialogueStyle {
        case greeting
        case motivation
    }
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(style == .greeting ? Color(red: 0.055, green: 0.259, blue: 0.184) : Color.white) // green
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(style == .greeting ? Color.white.opacity(0.9) : Color(red: 0.055, green: 0.259, blue: 0.184).opacity(0.9)) // green
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style == .greeting ? Color(red: 0.055, green: 0.259, blue: 0.184).opacity(0.2) : Color.clear, lineWidth: 1) // green
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            .frame(maxWidth: 280)
    }
}

struct StatsRow: View {
    let points: Int
    let streak: Int
    
    var body: some View {
        HStack(spacing: 20) {
            CharacterStatItem(icon: "star.fill", label: "Points", value: "\(points)", color: .yellow)
            CharacterStatItem(icon: "flame.fill", label: "Streak", value: "\(streak) days", color: .orange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.95, green: 0.95, blue: 0.95)) // light gray
        )
    }
}

struct CharacterStatItem: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// Comic-style outlined text used for the player name
struct OutlinedText: View {
    let text: String
    let font: Font
    let foreground: Color
    let outline: Color
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            // 8-direction outline around the text
            Text(text).font(font).foregroundColor(outline).offset(x:  lineWidth, y:  0)
            Text(text).font(font).foregroundColor(outline).offset(x: -lineWidth, y:  0)
            Text(text).font(font).foregroundColor(outline).offset(x:  0,          y:  lineWidth)
            Text(text).font(font).foregroundColor(outline).offset(x:  0,          y: -lineWidth)
            Text(text).font(font).foregroundColor(outline).offset(x:  lineWidth, y:  lineWidth)
            Text(text).font(font).foregroundColor(outline).offset(x: -lineWidth, y:  lineWidth)
            Text(text).font(font).foregroundColor(outline).offset(x:  lineWidth, y: -lineWidth)
            Text(text).font(font).foregroundColor(outline).offset(x: -lineWidth, y: -lineWidth)
            
            // Fill text on top
            Text(text).font(font).foregroundColor(foreground)
        }
    }
}

#Preview {
    CharacterCard(title: "Alex", size: 300)
        .environmentObject(PersonalityManager())
        .environmentObject(FocusManager())
        .padding()
        .background(Color("Background"))
}
