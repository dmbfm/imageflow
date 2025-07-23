import CommonUtils
import Logging
import SwiftUI
import SwiftUIUtils

public struct CanvasView<Content: View>: View {
    @Binding var viewport: CanvasViewport
    let content: () -> Content
    let configuration = CanvasConfiguration()

    public init(viewport: Binding<CanvasViewport>, @ViewBuilder content: @escaping () -> Content) {
        self._viewport = viewport
        self.content = content
    }

    public var body: some View {
        GridView(viewport: self.$viewport)
            .overlay(alignment: .topLeading) {
                ZStack(alignment: .topLeading) {
                    self.content()
                        .transformEffect(self.viewport.transform(from: .canvas, to: .screen))
                }
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
                .fill(.random.gradient)
                .shadow(radius: 4)

            Button("Hello!") {
                print("World!")
            }
        }
        .frame(width: 80, height: 80)
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
