import SwiftUI
import CoreImage.CIFilterBuiltins

enum AddFriendTab: String, CaseIterable {
    case search = "Search"
    case code = "Friend Code"
}

struct AddFriendView: View {
    @EnvironmentObject var friendsManager: FriendsManager
    @EnvironmentObject var personalityManager: PersonalityManager
    @Environment(\.dismiss) var dismiss
    
    @State private var searchQuery = ""
    @State private var isSearching = false
    @State private var selectedTab: AddFriendTab = .search
    @State private var friendCode = ""
    @State private var showShareSheet = false
    @State private var sentRequestIds: Set<UUID> = []
    
    // Debounced search
    @State private var searchTask: Task<Void, Never>?
    
    private var userFriendCode: String {
        // Generate a simple friend code from user ID (in real app, this would be server-generated)
        let userId = UserIdProvider.getOrCreate()
        return String(userId.suffix(8)).uppercased()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Add Friend Method", selection: $selectedTab) {
                    ForEach(AddFriendTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                // Tab Content
                switch selectedTab {
                case .search:
                    searchTabContent
                case .code:
                    friendCodeTabContent
                }
                
                Spacer()
            }
            .navigationTitle("Add Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            searchTask?.cancel()
            friendsManager.clearSearchResults()
        }
    }
    
    // MARK: - Search Tab
    
    private var searchTabContent: some View {
        VStack(spacing: 16) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search by name...", text: $searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: searchQuery) { _, newValue in
                        debouncedSearch(query: newValue)
                    }
                if !searchQuery.isEmpty {
                    Button("Clear") {
                        searchQuery = ""
                        friendsManager.clearSearchResults()
                    }
                    .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
            
            // Search Results
            if isSearching {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Searching...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !friendsManager.searchResults.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(friendsManager.searchResults) { result in
                            UserSearchResultRow(
                                result: result,
                                isRequestSent: sentRequestIds.contains(result.id)
                            ) {
                                sendFriendRequest(to: result.id)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else if !searchQuery.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No users found")
                        .font(.headline)
                    Text("Try searching with a different name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(personalityManager.currentTheme.secondary)
                    Text("Find Friends")
                        .font(.headline)
                    Text("Search for friends by their name to send friend requests")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Friend Code Tab
    
    private var friendCodeTabContent: some View {
        VStack(spacing: 24) {
            // Your Friend Code Section
            VStack(spacing: 16) {
                Text("Your Friend Code")
                    .font(.headline)
                    .foregroundColor(personalityManager.currentTheme.text)
                
                VStack(spacing: 12) {
                    // QR Code
                    if let qrImage = generateQRCode(from: userFriendCode) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    // Friend Code Text
                    Text(userFriendCode)
                        .font(.title2.monospaced())
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(personalityManager.currentTheme.primary.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(personalityManager.currentTheme.primary, lineWidth: 1)
                                )
                        )
                    
                    Button("Share Code") {
                        shareUserCode()
                    }
                    .buttonStyle(NavPillStyle(variant: .primary))
                }
                .padding(16)
                .retroConsoleSurface()
                .padding(.horizontal)
            }
            
            // Add by Code Section
            VStack(spacing: 16) {
                Text("Add by Friend Code")
                    .font(.headline)
                    .foregroundColor(personalityManager.currentTheme.text)
                
                VStack(spacing: 12) {
                    TextField("Enter friend's code", text: $friendCode)
                        .textFieldStyle(.roundedBorder)
                        .textCase(.uppercase)
                        .autocorrectionDisabled()
                    
                    Button("Add Friend") {
                        addFriendByCode()
                    }
                    .buttonStyle(NavPillStyle(variant: .primary))
                    .disabled(friendCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(16)
                .retroConsoleSurface()
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [userFriendCode])
        }
    }
    
    // MARK: - Helper Methods
    
    private func debouncedSearch(query: String) {
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            friendsManager.clearSearchResults()
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            
            if !Task.isCancelled {
                await performSearch(query: query)
            }
        }
    }
    
    @MainActor
    private func performSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isSearching = true
        
        do {
            try await friendsManager.searchUsers(query: query)
        } catch {
            // Error handling is managed by FriendsManager
        }
        
        isSearching = false
    }
    
    private func sendFriendRequest(to userId: UUID) {
        Task {
            do {
                try await friendsManager.sendFriendRequest(toUserId: userId)
                await MainActor.run {
                    sentRequestIds.insert(userId)
                }
            } catch {
                // Error handling could show an alert
                print("Failed to send friend request: \\(error)")
            }
        }
    }
    
    private func addFriendByCode() {
        // In a real app, this would lookup the user by friend code
        // For now, just show an alert
        print("Add friend by code: \\(friendCode)")
        friendCode = ""
    }
    
    private func shareUserCode() {
        showShareSheet = true
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}

// MARK: - Supporting Views

struct UserSearchResultRow: View {
    let result: UserSearchResult
    let isRequestSent: Bool
    let onSendRequest: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar using UserSearchResult's computed property
            Image(result.avatarImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(result.personalityColors.primary, lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(result.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(result.personalityType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Show mutual friends if any
                if result.mutualFriends > 0 {
                    Text(result.mutualFriendsText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Show focus points if available
            if let focusPoints = result.focusPoints {
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("\(focusPoints)")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                }
            }
            
            // Status button/badge
            if result.isFriend {
                Text("Friend")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.2))
                    )
                    .foregroundColor(.green)
            } else if result.hasPendingRequest || isRequestSent {
                Text("Pending")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.2))
                    )
                    .foregroundColor(.orange)
            } else {
                Button("Add") {
                    onSendRequest()
                }
                .buttonStyle(NavPillStyle(variant: .primary, compact: true))
            }
        }
        .padding(12)
        .retroConsoleSurface()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


#Preview {
    AddFriendView()
        .environmentObject(FriendsManager())
        .environmentObject(PersonalityManager())
}
