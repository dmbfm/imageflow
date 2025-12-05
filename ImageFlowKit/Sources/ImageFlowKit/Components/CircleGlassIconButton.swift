import SwiftUI

struct CircleGlassIconButton: View {
    let systemName: String
    var size: CGFloat = 48
    var glass: Glass = .regular
    var action: () -> ()

    init(_ systemName: String, size: CGFloat = 48, glass: Glass = .regular, _ action: @escaping () -> ()) {
        self.systemName = systemName
        self.size = size
        self.glass = glass
        self.action = action
    }

    var body: some View {
        Button {
            self.action()
        } label: {
            Image(systemName: systemName)
                .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .glassEffect(self.glass.interactive())
        .contentShape(Circle())
    }
}

#Preview {
    ZStack {
        Rectangle()
            .fill(Color.teal.gradient)

        CircleGlassIconButton("xmark") {}
    }
}
