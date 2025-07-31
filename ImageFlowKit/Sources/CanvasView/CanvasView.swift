import CommonUtils
import Logging
import SwiftUI
import SwiftUIUtils

public let canvasCoordinateSpaceName = "canvas"

#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

#if canImport(AppKit)
typealias PlatformRepresentable = NSViewRepresentable
#else
typealias PlatformRepresentable = UIViewRepresentable
#endif

public struct CanvasView: PlatformRepresentable {
    
    @Binding var viewport: CanvasViewport
    
    public init(_ viewport: Binding<CanvasViewport>) {
        self._viewport = viewport
    }
    
    #if canImport(AppKit)
    public func makeNSView(context: Context) -> CanvasPlatformView {
        self.makeView(context: context)
    }
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        self.upadateView(nsView, context)
    }
    #endif
    
    #if canImport(UIKit)
    public func makeUIView(context: Context) -> CanvasPlatformView {
        self.makeView(context: context)
    }
    public func updateUIView(_ uiView: CanvasPlatformView, context: Context) {
        self.upadateView(uiView, context)
    }
    #endif
    
    func makeView(context: Context) -> CanvasPlatformView {
        let view = CanvasPlatformView(viewport: .init())
        view.onEvent = { event in
            switch event {
            case .viewportDidChange(let viewport):
                self.viewport = viewport
            }
        }
        return view
    }
    
    func upadateView(_ view: CanvasPlatformView, _ context: Context) {
        if view.viewport != self.viewport {
            view.viewport = self.viewport
        }
    }
}

// public struct CanvasView<Content: View>: View {
//     @Binding var viewport: CanvasViewport
//     let content: () -> Content
//     let configuration = CanvasConfiguration()

//     public init(viewport: Binding<CanvasViewport>, @ViewBuilder content: @escaping () -> Content) {
//         self._viewport = viewport
//         self.content = content
//     }

//     public var body: some View {
//         GridView(viewport: self.$viewport)
//             .overlay(alignment: .topLeading) {
//                 ZStack(alignment: .topLeading) {
//                     self.content()
//                         .transformEffect(self.viewport.transform(from: .canvas, to: .screen))
//                 }
//             }
//             .canvasGestures(self.$viewport, configuration: self.configuration)
//             .clipped()
//             .coordinateSpace(name: canvasCoordinateSpaceName)
//             .onChange(of: self.viewport) {
//                 log("CanvasView: viewport: \(self.viewport)", level: .debug)
//             }
//     }
// }

// public struct PinkNodeView: View {
//     public init() {}
//     public var body: some View {
//         ZStack {
//             RoundedRectangle(cornerRadius: 20)
//                 .fill(.random.gradient)
//                 .shadow(radius: 4)

//             Button("Hello!") {
//                 print("World!")
//             }
//         }
//         .frame(width: 80, height: 80)
//     }
// }

#Preview {
    // @Previewable @State var viewport = CanvasViewport()
    // CanvasView(viewport: $viewport) {
    //     PinkNodeView()
    //         .offset(x: 0, y: 15)
    // }
    // .border(.gray.opacity(0.25))
    // .padding()
}
