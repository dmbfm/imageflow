import CommonUtils
import SwiftUI

public struct CanvasView<Content: View>: View {
    @Binding var viewport: CanvasViewport
    let content: () -> Content
    let configuration = CanvasConfiguration()

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
        .canvasGestures(self.$viewport, configuration: self.configuration)
        .clipped()
    }
}

public struct PinkNodeView: View {
    public init() {}
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.pink.gradient)
                .shadow(radius: 4)

            Button("Hello!") {
                print("World!")
            }
        }
        .frame(width: 200, height: 350)
    }
}

#Preview {
    @Previewable @State var viewport = CanvasViewport()
    CanvasView(viewport: $viewport) {
        PinkNodeView()
            .offset(x: 0, y: 15)
    }
    .border(.gray.opacity(0.25))
    .padding()
}
