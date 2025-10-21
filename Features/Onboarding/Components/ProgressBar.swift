import SwiftUI

struct ProgressBar: View {
    var progress: CGFloat // 0...1
    var color: Color = .nudgeGreen900

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(color.opacity(0.15))
                Capsule().fill(color)
                    .frame(width: max(0, min(1, progress)) * geo.size.width)
            }
        }
        .frame(height: 8)
    }
}

