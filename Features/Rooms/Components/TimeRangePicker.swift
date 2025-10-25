import SwiftUI

struct TimeRangePicker: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    @Binding var isValid: Bool
    
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("Session Time")
                    .font(.custom("Tanker-Regular", size: 18))
                    .foregroundColor(Color.guildText)
                Spacer()
            }
            
            // Time picker row
            HStack(spacing: 16) {
                // Start time picker
                VStack(spacing: 8) {
                    Text("Start")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.guildTextSecondary)
                    
                    timePickerDisplay(time: startTime)
                        .onTapGesture {
                            // In a real implementation, this would show a time picker modal
                        }
                }
                .frame(maxWidth: .infinity)
                
                // Arrow
                VStack {
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.nudgeGreen900)
                    Spacer()
                }
                
                // End time picker
                VStack(spacing: 8) {
                    Text("End")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.guildTextSecondary)
                    
                    timePickerDisplay(time: endTime)
                        .onTapGesture {
                            // In a real implementation, this would show a time picker modal
                        }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Duration display
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(Color.nudgeGreen900)
                    .font(.system(size: 14))
                
                Text("Duration: \(durationText)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.guildText)
                
                Spacer()
            }
            
            // Error message
            if showError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                    
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Native time pickers (hidden but functional)
            HStack {
                DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .onChange(of: startTime) { _, _ in
                        validateTimes()
                    }
                
                Spacer()
                
                DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .onChange(of: endTime) { _, _ in
                        validateTimes()
                    }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.defaultCream)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(showError ? Color.red : Color.nudgeGreen900, lineWidth: 2)
                )
                .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 12, x: 0, y: 8)
        )
        .onAppear {
            validateTimes()
        }
    }
    
    // MARK: - Time Display Component
    private func timePickerDisplay(time: Date) -> some View {
        ZStack {
            // Timer square styling from FooterFocusBarView
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.nudgeGreen900, lineWidth: 3)
                )
                .shadow(color: Color.nudgeGreen900, radius: 0, x: 0, y: 4)
                .shadow(color: Color.nudgeGreen900.opacity(0.2), radius: 8, x: 0, y: 6)
                // Top highlight for glossy effect
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                )
            
            // Time text
            Text(formatTime(time))
                .font(.custom("Nippo-Regular", size: 20, relativeTo: .title3))
                .kerning(-0.5)
                .foregroundColor(Color.nudgeGreen900)
                .monospacedDigit()
        }
        .frame(height: 60)
    }
    
    // MARK: - Computed Properties
    private var durationText: String {
        let duration = endTime.timeIntervalSince(startTime)
        
        guard duration > 0 else {
            return "Invalid"
        }
        
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private var errorMessage: String {
        let duration = endTime.timeIntervalSince(startTime)
        
        if duration <= 0 {
            return "End time must be after start time"
        } else if duration < 15 * 60 { // 15 minutes
            return "Minimum session duration is 15 minutes"
        } else if duration > 8 * 60 * 60 { // 8 hours
            return "Maximum session duration is 8 hours"
        }
        
        return ""
    }
    
    // MARK: - Helper Methods
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func validateTimes() {
        let duration = endTime.timeIntervalSince(startTime)
        let minDuration: TimeInterval = 15 * 60 // 15 minutes
        let maxDuration: TimeInterval = 8 * 60 * 60 // 8 hours
        
        let wasShowingError = showError
        
        isValid = duration > 0 && duration >= minDuration && duration <= maxDuration
        showError = !isValid
        
        // Animate error message appearance/disappearance
        if wasShowingError != showError {
            withAnimation(.easeInOut(duration: 0.3)) {
                // Animation handled by transition modifier
            }
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var startTime = Date()
        @State private var endTime = Date().addingTimeInterval(3600) // 1 hour later
        @State private var isValid = true
        
        var body: some View {
            VStack(spacing: 20) {
                TimeRangePicker(
                    startTime: $startTime,
                    endTime: $endTime,
                    isValid: $isValid
                )
                
                Text("Valid: \(isValid ? "✅" : "❌")")
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            .background(Color.guildParchment)
        }
    }
    
    return PreviewWrapper()
}
