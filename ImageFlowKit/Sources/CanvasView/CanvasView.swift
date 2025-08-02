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

@MainActor
public struct CanvasView {

    @Binding var viewport: CanvasViewport
    @Binding var nodePositions: [UUID: CGPoint]

    let viewForNode: (UUID) -> (any CanvasNodeView)?

    public init(
        _ viewport: Binding<CanvasViewport>,
        _ nodePositions: Binding<[UUID: CGPoint]>,
        _ viewForNode: @escaping (UUID) -> (any CanvasNodeView)? = { _ in nil }
    ) {
        self._viewport = viewport
        self._nodePositions = nodePositions
        self.viewForNode = viewForNode
    }

    func makeView(context: Context) -> CanvasPlatformView {
        let view = CanvasPlatformView(
            viewport: self.viewport,
            nodePositions: self.nodePositions,
            configuration: .init(),
            viewForNode: self.viewForNode
        )
        view.onEvent = { event in
            switch event {
            case .viewportDidChange(let viewport):
                self.viewport = viewport
            case .nodePositionsDidChange(let nodePositions):
                self.nodePositions = nodePositions
            }
        }
        return view
    }

    func upadateView(_ view: CanvasPlatformView, _ context: Context) {
        if view.viewport != self.viewport {
            view.viewport = self.viewport
        }

        if view.nodePositions != self.nodePositions {
            log("updating node position!")
            view.nodePositions = self.nodePositions
        }
    }
}

#if canImport(AppKit)
typealias PlatformRepresentable = NSViewRepresentable
#else
typealias PlatformRepresentable = UIViewRepresentable
#endif

extension CanvasView: PlatformRepresentable {
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
