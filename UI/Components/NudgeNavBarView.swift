// UI/Components/NudgeNavBarView.swift
import SwiftUI

struct NudgeNavBarView: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("NUDGE")
                .font(.custom("Tanker-Regular", size: 24))
                .foregroundColor(Color.nudgeGreen900)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(Color(red: 0.988, green: 0.973, blue: 0.949))
                .ignoresSafeArea(edges: .top)
        )
        .mask(
            BottomRoundedRectangle(radius: 20)
                .ignoresSafeArea(edges: .top)
        )
        .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
        .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
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

