import SwiftUI

public struct CanvasView<Content: View>: View {

    @Binding var viewport: CanvasViewport
    let content: () -> Content

    public init(viewport: Binding<CanvasViewport>, @ViewBuilder content: @escaping () -> Content) {
        self._viewport = viewport
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            GridView(viewport: self.$viewport)
            self.content()
                .transformEffect(self.viewport.transform(from: .canvas, to: .screen))
        }
        .clipped()
    }
}

public struct PinkNodeView: View {
    public init() {}
    public var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.pink.gradient)
            .frame(width: 200, height: 350)
            .shadow(radius: 4)
    }
}

#Preview {
    @Previewable @State var viewport = CanvasViewport()

    CanvasView(viewport: $viewport) {

    }
    .border(.gray.opacity(0.25))
    .padding()
}
