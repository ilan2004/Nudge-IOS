import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🎯 Nudge iOS")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Personality-Driven Focus App")
                .font(.title2)
                .foregroundColor(.secondary)
            
            VStack(spacing: 10) {
                Text("✅ iOS Build Working")
                Text("✅ Codemagic Integration")
                Text("✅ Ready for Development")
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.063, green: 0.737, blue: 0.502), // Mint
                    Color(red: 0.439, green: 0.859, blue: 0.804)  // Teal
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.1)
            .ignoresSafeArea()
        )
    }
}

#Preview {
    ContentView()
}
