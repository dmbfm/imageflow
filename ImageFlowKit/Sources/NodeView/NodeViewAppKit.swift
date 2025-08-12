//
//  NodeViewAppKit.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 05/08/25.
//
//

#if canImport(AppKit)
import AppKit
import CanvasView
import Models
import EventEmitter

public final class NodeViewAppKit: NSView, CanvasNodeView {
    public var node: FlowNode
    public var id: UUID { self.node.id }

    public var emitter: EventEmitter<CanvasNodeEvent<()>> = .init()

    init(_ node: FlowNode) {
        self.node = node
        super.init(frame: .zero)
    }

    public required init?(coder: NSCoder) {
        nil
    }
}
#endif
