import SwiftUI

struct ContentView: View {
    @EnvironmentObject var personalityManager: PersonalityManager
    @EnvironmentObject var appSettings: AppSettings
    
    // Exact mint: rgb(130, 237, 166)
    private let exactMint = Color(red: 130/255, green: 237/255, blue: 166/255)
    
    var body: some View {
        DashboardView()
            .background(exactMint.ignoresSafeArea())
            .preferredColorScheme(appSettings.colorScheme)
    }
}

#Preview {
    ContentView()
        .environmentObject(PersonalityManager())
        .environmentObject(AppSettings())
        .environmentObject(FocusManager())
}
