// UI/Components/NudgeNavBarView.swift
import SwiftUI

struct NudgeNavBarView: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("nudge")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.nudgeGreen900)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .retroConsoleSurface()
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 0) {
        NudgeNavBarView()
        Spacer()
    }
    .background(Color(red: 0.96, green: 0.96, blue: 0.94))
}

