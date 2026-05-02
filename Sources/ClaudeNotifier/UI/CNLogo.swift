import SwiftUI

/// Replicates the app icon — same colors, radial depth, and corner radius.
struct CNLogo: View {
    var size: CGFloat = 32

    private var cornerRadius: CGFloat {
        size * 0.22
    }

    private var fontSize: CGFloat {
        size >= 20 ? size * 0.44 : size * 0.60
    }

    private var label: String {
        size >= 20 ? "CN" : "C"
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.iconBackground)
            .frame(width: size, height: size)
            .overlay { depthGradient }
            .overlay {
                Text(label)
                    .font(.system(size: fontSize, weight: .semibold, design: .default))
                    .foregroundColor(Color.iconForeground)
                    .tracking(fontSize * 0.04)
                    .offset(y: size * 0.01)
            }
    }

    private var depthGradient: some View {
        RadialGradient(
            colors: [
                Color(red: 0.20, green: 0.20, blue: 0.30).opacity(0.5),
                Color(red: 0.07, green: 0.07, blue: 0.10).opacity(0)
            ],
            center: .center,
            startRadius: 0,
            endRadius: size * 0.70
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
