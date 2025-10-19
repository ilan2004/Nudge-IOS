import SwiftUI

struct FocusRing: View {
    let size: CGFloat
    let stroke: CGFloat
    let value: Double // 0..1
    let mode: String // "focus" | "break" | "paused" | "idle"
    
    init(size: CGFloat = 560, stroke: CGFloat = 10, value: Double = 0, mode: String = "focus") {
        self.size = size
        self.stroke = stroke
        self.value = max(0, min(1, value))
        self.mode = mode
    }
    
    private var radius: CGFloat {
        (size - stroke) / 2
    }
    
    private var innerRadius: CGFloat {
        radius - 4
    }
    
    private var circumference: CGFloat {
        2 * .pi * innerRadius
    }
    
    private var progress: CGFloat {
        CGFloat(value)
    }
    
    private var color: Color {
        switch mode {
        case "break":
            return Color(red: 0.392, green: 0.584, blue: 0.929) // blue
        case "paused":
            return Color(red: 0.439, green: 0.859, blue: 0.804) // teal
        case "focus":
            return Color(red: 0.055, green: 0.259, blue: 0.184) // green
        default:
            return Color(red: 0.055, green: 0.259, blue: 0.184).opacity(0.2) // green with opacity
        }
    }
    
    var body: some View {
        ZStack {
            // Background circle with nav-pill styling
            Circle()
                .fill(Color(red: 0.988, green: 0.973, blue: 0.949)) // cream surface
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color(red: 0.055, green: 0.259, blue: 0.184), lineWidth: 2) // green
                )
                .shadow(color: Color(red: 0.055, green: 0.259, blue: 0.184), radius: 0, x: 0, y: 4)
                .shadow(color: Color(red: 0.055, green: 0.259, blue: 0.184).opacity(0.2), radius: 12, x: 0, y: 8)
            
            // SVG-like progress ring
            ZStack {
                // Track (background ring)
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: stroke)
                    .frame(width: innerRadius * 2, height: innerRadius * 2)
                
                // Progress ring underlay (border effect)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color(red: 0.055, green: 0.259, blue: 0.184), // green
                        style: StrokeStyle(lineWidth: stroke + 2, lineCap: .round)
                    )
                    .frame(width: innerRadius * 2, height: innerRadius * 2)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Color.black.opacity(0.2), radius: 2.5, x: 0, y: 4)
                
                // Colored progress overlay
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: stroke, lineCap: .round)
                    )
                    .frame(width: innerRadius * 2, height: innerRadius * 2)
                    .rotationEffect(.degrees(-90))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 30) {
        FocusRing(size: 200, stroke: 8, value: 0.0, mode: "idle")
        FocusRing(size: 200, stroke: 8, value: 0.3, mode: "focus")
        FocusRing(size: 200, stroke: 8, value: 0.7, mode: "break")
        FocusRing(size: 200, stroke: 8, value: 1.0, mode: "paused")
    }
    .padding()
}
