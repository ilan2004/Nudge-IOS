import SwiftUI

enum NudgeMessage: String, CaseIterable {
    case keepGoing = "Keep going! 💪"
    case focusTime = "Time to focus! 🎯"
    case youGotThis = "You got this! ⭐"
    case stayStrong = "Stay strong! 🔥"
    case almostThere = "Almost there! 🏃‍♂️"
    case custom = "Custom message"
    
    var text: String {
        return self.rawValue
    }
    
    var emoji: String {
        switch self {
        case .keepGoing: return "💪"
        case .focusTime: return "🎯"
        case .youGotThis: return "⭐"
        case .stayStrong: return "🔥"
        case .almostThere: return "🏃‍♂️"
        case .custom: return "✏️"
        }
    }
}

struct SendNudgeView: View {
    @EnvironmentObject var friendsManager: FriendsManager
    @Environment(\.dismiss) var dismiss
    
    let friend: Friend
    
    @State private var selectedMessage: NudgeMessage = .keepGoing
    @State private var customMessage = ""
    @State private var isSending = false
    @State private var showError: String?
    
    private let characterLimit = 100
    
    private var finalMessage: String {
        if selectedMessage == .custom {
            return customMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return selectedMessage.text
        }
    }
    
    private var canSend: Bool {
        if selectedMessage == .custom {
            return !customMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            // Friend info header
            VStack(spacing: 12) {
                Image(friend.avatarImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(friend.personalityColors.primary, lineWidth: 2)
                    )
                
                Text("Send Nudge to \(friend.name)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Give them a gentle push to stay focused!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Message selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Choose your message:")
                    .font(.headline)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(NudgeMessage.allCases.filter { $0 != .custom }, id: \.self) { message in
                        MessageCard(
                            message: message,
                            isSelected: selectedMessage == message
                        ) {
                            selectedMessage = message
                        }
                    }
                }
                
                // Custom message option
                MessageCard(
                    message: .custom,
                    isSelected: selectedMessage == .custom
                ) {
                    selectedMessage = .custom
                }
                
                // Custom message input
                if selectedMessage == .custom {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Write your motivational message...", text: $customMessage, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...5)
                            .onChange(of: customMessage) { _, newValue in
                                if newValue.count > characterLimit {
                                    customMessage = String(newValue.prefix(characterLimit))
                                }
                            }
                        
                        HStack {
                            Spacer()
                            Text("\(customMessage.count)/\(characterLimit)")
                                .font(.caption2)
                                .foregroundColor(customMessage.count > characterLimit * 3/4 ? .orange : .secondary)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            
            Spacer()
            
            // Send button
            Button(action: sendNudge) {
                HStack {
                    if isSending {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Text(isSending ? "Sending..." : "Send Nudge")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(NavPillStyle(variant: .primary))
            .disabled(!canSend || isSending)
            .padding(.bottom)
        }
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.regularMaterial)
        )
        .alert("Error", isPresented: .constant(showError != nil)) {
            Button("OK") {
                showError = nil
            }
        } message: {
            if let error = showError {
                Text(error)
            }
        }
    }
    
    private func sendNudge() {
        guard canSend else { return }
        
        isSending = true
        
        Task {
            do {
                try await friendsManager.sendNudge(
                    toFriendId: friend.id,
                    message: finalMessage
                )
                
                await MainActor.run {
                    // Success haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    // Success notification feedback
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.success)
                    
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    showError = "Failed to send nudge: \(error.localizedDescription)"
                    isSending = false
                }
            }
        }
    }
}

// MARK: - Message Card

private struct MessageCard: View {
    let message: NudgeMessage
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text(message.emoji)
                    .font(.title2)
                
                if message == .custom {
                    Text("Custom")
                        .font(.subheadline)
                        .fontWeight(.medium)
                } else {
                    Text(message.text)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
            .foregroundColor(isSelected ? .blue : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SendNudgeView(friend: Friend.mockFriends[0])
        .environmentObject(FriendsManager())
        .presentationDetents([.height(400)])
}
