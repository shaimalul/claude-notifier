import SwiftUI

struct InfoButton: View {
    let text: String
    @State private var isShowing = false

    var body: some View {
        Button {
            isShowing.toggle()
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 12))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isShowing, arrowEdge: .bottom) {
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.primary)
                .lineSpacing(3)
                .padding(14)
                .frame(maxWidth: 260)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
