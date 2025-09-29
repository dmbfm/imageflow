import Logging
import SwiftUI
import Values
import Helpers

#if canImport(AppKit)
import AppKit
typealias NodeView = NodeNSView
#endif

#if canImport(UIKit)
import UIKit
typealias NodeView = NodeUIView
#endif

// MARK: - Event

@MainActor
protocol NodeViewProtocol {
    var node: FlowNode { get set }
    var isSelected: Bool { get set }
    var emitter: EventEmitter<CanvasNodeEvent<NodeView.Event>> { get }
    init(_ node: FlowNode, _ isSelected: Bool)
}

extension NodeView {
    public enum Event {
        case valueDidChange(Int, Value)
        case dragPort(PortLocation, PortView.DragData)
    }

    public var ports: [(PortLocation, PortView)] {
        self.inputBlockView.rows.enumerated().map {
            (.init(node: self.id, port: .input($0.offset)), $0.element.portView)
        }
            + self.outputBlockView.rows.enumerated().map {
                (.init(node: self.id, port: .output($0.offset)), $0.element.portView)
            }
    }

    public func setDrawPortAsConnected(_ slot: PortSlot, _ value: Bool) {
        switch slot {
        case .input(let index):
            self.inputBlockView.rows[index].drawPortAsConnected = value
        case .output(let index):
            self.outputBlockView.rows[index].drawPortAsConnected = value
        }
    }
}

// MARK: - Ports

extension NodeView {
    /// Returns the window-coordinate frame of the port at `location`.
    /// - Parameter slot: The slot we want the frame for.
    /// - Returns: The frame, if the slot is valid.
    public func portFrame(_ slot: PortSlot) -> CGRect? {
        switch slot {
        case .input(let port):
            if port >= self.inputBlockView.rows.count {
                return nil
            }
            let frame = self.inputBlockView.rows[port].portView.frame
            return self.inputBlockView.rows[port].convert(frame, to: nil)
        case .output(let port):
            if port >= self.outputBlockView.rows.count {
                return nil
            }
            let frame = self.outputBlockView.rows[port].portView.frame
            return self.outputBlockView.rows[port].convert(frame, to: nil)
        }
    }

    /// Returns the `PortView` for the given slot.
    /// - Parameter slot:
    /// - Returns:
    public func portView(_ slot: PortSlot) -> PortView? {
        switch slot {
        case .input(let idx):
            if idx < 0 || idx >= self.inputBlockView.rows.count {
                return nil
            }
            return self.inputBlockView.rows[idx].portView
        case .output(let idx):
            if idx < 0 || idx >= self.outputBlockView.rows.count {
                return nil
            }
            return self.outputBlockView.rows[idx].portView
        }
    }
}

// MARK: - Previews

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
    .frame(minWidth: 300, minHeight: 300)
    .background(Colors.canvasBackground.color)
}

//#Preview("Gaussian Blur", traits: .sizeThatFitsLayout) {
//    VStack {
//        NodeView.Preview(node: .init(kind: .coreImageFilterNode(.gaussianBlur)))
//    }
//    .frame(minWidth: 300, minHeight: 300)
//    .background(Colors.canvasBackground.color)
//}
//
//#Preview("KMeans", traits: .sizeThatFitsLayout) {
//    VStack {
//        NodeView.Preview(node: .init(kind: .coreImageFilterNode(.kMeans)))
//    }
//    .frame(minWidth: 300, minHeight: 300)
//    .background(Colors.canvasBackground.color)
//}
