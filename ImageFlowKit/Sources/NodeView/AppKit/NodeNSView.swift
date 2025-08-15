#if canImport(AppKit)

import AppKit
import Models
import CanvasView
import EventEmitter

public final class NodeNSView: NSView, CanvasNodeView {
    public var id: UUID { self.node.id }

    public var emitter: EventEmitter<CanvasNodeEvent<Event>> = .init()

    public init(_ node: FlowNode) {
        self.node = node
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        nil
    }

    public var node: FlowNode

}

#endif
