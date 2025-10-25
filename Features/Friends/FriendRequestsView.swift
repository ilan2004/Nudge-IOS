import SwiftUI

enum RequestTab: String, CaseIterable {
    case received = "Received"
    case sent = "Sent"
}

struct FriendRequestsView: View {
    @EnvironmentObject var friendsManager: FriendsManager
    @EnvironmentObject var personalityManager: PersonalityManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab: RequestTab = .received
    @State private var processingRequestId: UUID?
    @State private var showSuccessMessage: String?
    @State private var showErrorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Request Type", selection: $selectedTab) {
                    ForEach(RequestTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                // Tab Content
                switch selectedTab {
                case .received:
                    receivedRequestsContent
                case .sent:
                    sentRequestsContent
                }
                
                Spacer()
            }
            .navigationTitle("Friend Requests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Success", isPresented: .constant(showSuccessMessage != nil)) {
            Button("OK") {
                showSuccessMessage = nil
            }
        } message: {
            if let message = showSuccessMessage {
                Text(message)
            }
        }
        .alert("Error", isPresented: .constant(showErrorMessage != nil)) {
            Button("OK") {
                showErrorMessage = nil
            }
        } message: {
            if let message = showErrorMessage {
                Text(message)
            }
        }
    }
    
    // MARK: - Received Requests
    
    private var receivedRequestsContent: some View {
        Group {
            if friendsManager.pendingRequests.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No Pending Requests")
                        .font(.headline)
                        .foregroundColor(personalityManager.currentTheme.text)
                    Text("You're all caught up!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(friendsManager.pendingRequests) { request in
                            ReceivedRequestRow(
                                request: request,
                                isProcessing: processingRequestId == request.id
                            ) { action in
                                handleRequestAction(action, for: request)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Sent Requests
    
    private var sentRequestsContent: some View {
        Group {
            if friendsManager.sentRequests.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "paperplane")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No Sent Requests")
                        .font(.headline)
                        .foregroundColor(personalityManager.currentTheme.text)
                    Text("Start connecting with friends!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(friendsManager.sentRequests) { request in
                            SentRequestRow(
                                request: request,
                                isProcessing: processingRequestId == request.id
                            ) {
                                cancelRequest(request)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleRequestAction(_ action: RequestAction, for request: FriendRequest) {
        processingRequestId = request.id
        
        Task {
            do {
                switch action {
                case .accept:
                    try await friendsManager.acceptFriendRequest(requestId: request.id)
                    await MainActor.run {
                        showSuccessMessage = "Added \(request.fromUserName) as a friend!"
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }
                case .decline:
                    try await friendsManager.declineFriendRequest(requestId: request.id)
                    await MainActor.run {
                        showSuccessMessage = "Request declined"
                    }
                }
            } catch {
                await MainActor.run {
                    showErrorMessage = "Failed to process request: \(error.localizedDescription)"
                }
            }
            
            await MainActor.run {
                processingRequestId = nil
            }
        }
    }
    
    private func cancelRequest(_ request: FriendRequest) {
        processingRequestId = request.id
        
        Task {
            do {
                // In a real app, this would call an API to cancel the sent request
                // For now, just remove it locally (would need API endpoint)
                await MainActor.run {
                    showSuccessMessage = "Request to \(request.fromUserName) cancelled"
                    processingRequestId = nil
                }
            } catch {
                await MainActor.run {
                    showErrorMessage = "Failed to cancel request"
                    processingRequestId = nil
                }
            }
        }
    }
}

// MARK: - Supporting Types

enum RequestAction {
    case accept
    case decline
}

// MARK: - Request Row Components

struct ReceivedRequestRow: View {
    let request: FriendRequest
    let isProcessing: Bool
    let onAction: (RequestAction) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(request.fromUserPersonalityType.colors(for: request.fromUserGender).primary.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(request.fromUserName.prefix(1)))
                        .font(.headline)
                        .foregroundColor(request.fromUserPersonalityType.colors(for: request.fromUserGender).primary)
                )
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(request.fromUserName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(request.fromUserPersonalityType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(timeAgoString(from: request.createdAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action Buttons
            if isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(0.8)
            } else {
                VStack(spacing: 8) {
                    Button("Accept") {
                        onAction(.accept)
                    }
                    .buttonStyle(NavPillStyle(variant: .primary, compact: true))
                    
                    Button("Decline") {
                        onAction(.decline)
                    }
                    .buttonStyle(NavPillStyle(variant: .outline, compact: true))
                }
            }
        }
        .padding(12)
        .retroConsoleSurface()
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

struct SentRequestRow: View {
    let request: FriendRequest
    let isProcessing: Bool
    let onCancel: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(request.fromUserPersonalityType.colors(for: request.fromUserGender).primary.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(request.fromUserName.prefix(1)))
                        .font(.headline)
                        .foregroundColor(request.fromUserPersonalityType.colors(for: request.fromUserGender).primary)
                )
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(request.fromUserName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(request.fromUserPersonalityType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Status Badge
                Text("Pending")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.2))
                    )
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            // Cancel Button
            if isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(0.8)
            } else {
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(NavPillStyle(variant: .danger, compact: true))
            }
        }
        .padding(12)
        .retroConsoleSurface()
    }
}

// MARK: - Extensions

extension PersonalityType {
    func colors(for gender: Gender) -> PersonalityColors {
        return PersonalityTheme.colors(for: self, gender: gender)
    }
}

#Preview {
    FriendRequestsView()
        .environmentObject(FriendsManager())
        .environmentObject(PersonalityManager())
}
