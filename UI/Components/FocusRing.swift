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
            return Color("BlueAccent") // var(--color-blue-400)
        case "paused":
            return Color("TealAccent") // var(--color-teal-300)
        case "focus":
            return Color("GreenPrimary") // var(--color-green-900)
        default:
            return Color("GreenPrimary").opacity(0.2) // var(--color-green-900-20)
        }
    }
    
    var body: some View {
        ZStack {
            // Background circle with nav-pill styling
            Circle()
                .fill(Color("Surface"))
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color("GreenPrimary"), lineWidth: 2)
                )
                .shadow(color: Color("GreenPrimary"), radius: 0, x: 0, y: 4)
                .shadow(color: Color("GreenPrimary").opacity(0.2), radius: 12, x: 0, y: 8)
            
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
                        Color("GreenPrimary"),
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
