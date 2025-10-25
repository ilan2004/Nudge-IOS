import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct DaySelector: View {
    @Binding var selectedDays: Set<Int>
    
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    private let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    private let buttonSize: CGFloat = 44
    
    var body: some View {
        VStack(spacing: 12) {
            // Title
            HStack {
                Text("Days")
                    .font(.custom("Tanker-Regular", size: 18))
                    .foregroundColor(Color.guildText)
                Spacer()
            }
            
            // Day buttons
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { dayIndex in
                    dayButton(for: dayIndex)
                }
            }
            
            // Helper text
            Text(selectedDaysText)
                .font(.caption)
                .foregroundColor(Color.guildTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
    
    // MARK: - Day Button
    private func dayButton(for dayIndex: Int) -> some View {
        Button(action: {
            toggleDay(dayIndex)
        }) {
            Text(dayLabels[dayIndex])
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(foregroundColor(for: dayIndex))
        }
        .frame(width: buttonSize, height: buttonSize)
        .background(backgroundColor(for: dayIndex))
        .overlay(
            Circle()
                .stroke(borderColor(for: dayIndex), lineWidth: 2)
        )
        .shadow(
            color: shadowColor(for: dayIndex),
            radius: selectedDays.contains(dayIndex) ? 4 : 0,
            x: 0,
            y: selectedDays.contains(dayIndex) ? 2 : 0
        )
        .scaleEffect(selectedDays.contains(dayIndex) ? 1.0 : 0.95)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedDays.contains(dayIndex))
        .accessibilityLabel(dayNames[dayIndex])
        .accessibilityValue(selectedDays.contains(dayIndex) ? "selected" : "not selected")
        .accessibilityAddTraits(selectedDays.contains(dayIndex) ? .isSelected : [])
        .accessibilityHint("Double tap to toggle selection")
    }
    
    // MARK: - Actions
    private func toggleDay(_ dayIndex: Int) {
        // Haptic feedback
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if selectedDays.contains(dayIndex) {
                // Don't allow deselecting if it's the last selected day
                if selectedDays.count > 1 {
                    selectedDays.remove(dayIndex)
                } else {
                    // Provide feedback that at least one day must be selected
                    #if canImport(UIKit)
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    #endif
                }
            } else {
                selectedDays.insert(dayIndex)
                
                // Success feedback when selecting
                #if canImport(UIKit)
                UISelectionFeedbackGenerator().selectionChanged()
                #endif
            }
        }
    }
    
    // MARK: - Styling Helpers
    private func foregroundColor(for dayIndex: Int) -> Color {
        if selectedDays.contains(dayIndex) {
            return .white
        } else {
            return Color.nudgeGreen900
        }
    }
    
    private func backgroundColor(for dayIndex: Int) -> some View {
        Circle()
            .fill(selectedDays.contains(dayIndex) ? Color.nudgeGreen900 : Color.clear)
    }
    
    private func borderColor(for dayIndex: Int) -> Color {
        if selectedDays.contains(dayIndex) {
            return Color.nudgeGreen900
        } else if selectedDays.isEmpty {
            return Color.gray.opacity(0.5) // Show as disabled if no days selected
        } else {
            return Color.nudgeGreen900.opacity(0.6)
        }
    }
    
    private func shadowColor(for dayIndex: Int) -> Color {
        selectedDays.contains(dayIndex) ? Color.nudgeGreen900.opacity(0.3) : Color.clear
    }
    
    // MARK: - Computed Properties
    private var selectedDaysText: String {
        if selectedDays.isEmpty {
            return "Select at least one day for recurring sessions"
        } else if selectedDays.count == 7 {
            return "Every day"
        } else if selectedDays.count == 1 {
            let dayIndex = selectedDays.first!
            return "Every \(dayNames[dayIndex])"
        } else {
            // Sort days and create readable text
            let sortedDays = selectedDays.sorted()
            
            // Check for common patterns
            let weekdays: Set<Int> = [1, 2, 3, 4, 5] // Monday to Friday
            let weekends: Set<Int> = [0, 6] // Sunday and Saturday
            
            if selectedDays == weekdays {
                return "Weekdays (Mon-Fri)"
            } else if selectedDays == weekends {
                return "Weekends (Sat-Sun)"
            } else {
                let dayAbbreviations = sortedDays.map { dayLabels[$0] }
                return dayAbbreviations.joined(separator: " ")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5] // Weekdays
        
        var body: some View {
            VStack(spacing: 30) {
                DaySelector(selectedDays: $selectedDays)
                
                VStack(spacing: 8) {
                    Text("Selected Days:")
                        .font(.headline)
                    
                    Text("\(selectedDays.sorted().map { String($0) }.joined(separator: ", "))")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    if selectedDays.isEmpty {
                        Text("⚠️ At least one day must be selected")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Test buttons
                HStack(spacing: 16) {
                    Button("Weekdays") {
                        selectedDays = [1, 2, 3, 4, 5]
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Weekends") {
                        selectedDays = [0, 6]
                    }
                    .buttonStyle(.bordered)
                    
                    Button("All Days") {
                        selectedDays = Set(0..<7)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Clear") {
                        selectedDays = []
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.guildParchment)
        }
    }
    
    return PreviewWrapper()
}
