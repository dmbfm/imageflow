import CanvasView
import ColorUtils
import Design
import Easing
import EventEmitter
import Models
import PlatformUtils
import SwiftUI
import Logging
import Values

#if canImport(AppKit)
import AppKit
public typealias NodeView = NodeViewAppKit
#endif

#if canImport(UIKit)
import UIKit
public typealias NodeView = NodeUIView
#endif

extension NodeView {
    public enum Event {
        case valueDidChange(Int, Value)
    }
}

extension NodeView {
    public struct Preview: PlatformViewRepresentable {
        let node: FlowNode
        public init(node: FlowNode) {
            self.node = node
        }
        public func makeView(context: Context) -> some PlatformView {
            let view = NodeView(node)
            view.emitter.on { event in
                log("event: \(event)")
            }
            return view
        }

        public func updateView(_ view: ViewType, context: Context) {
        }

        public func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview("Add", traits: .sizeThatFitsLayout) {
    VStack {
        NodeView.Preview(node: .init(kind: .addNode(.float)))
    }
    .padding(50)
//    .frame(width: 300, height: 300)
    .background(Colors.canvasBackground.color)
}

#Preview("Gaussian Blur", traits: .sizeThatFitsLayout) {
    VStack {
        NodeView.Preview(node: .init(kind: .coreImageFilterNode(.gaussianBlur)))
    }
    .padding(50)
//    .frame(width: 300, height: 300)
    .background(Colors.canvasBackground.color)
}

#Preview("KMeans", traits: .sizeThatFitsLayout) {
    VStack {
        NodeView.Preview(node: .init(kind: .coreImageFilterNode(.kMeans)))
    }
    .padding(50)
//    .frame(width: 300, height: 300)
    .background(Colors.canvasBackground.color)
}
