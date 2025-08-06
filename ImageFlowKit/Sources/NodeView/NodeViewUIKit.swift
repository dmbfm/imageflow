//
//  NodeViewUIKit.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//

import UIKit
import CanvasView
import Models
import EventEmitter

public final class NodeViewUIKit: UIView, CanvasNodeView {
    public var node: FlowNode
    public var id: UUID { self.node.id }
    
    public var emitter: EventEmitter<CanvasNodeEvent<Event>> = .init()
    
    init(_ node: FlowNode) {
        self.node = node
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) {
        nil
    }
}
