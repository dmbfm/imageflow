//
//
//  NodeOutputRowUIView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 11/08/25.
//

#if canImport(AppKit)

import AppKit
import Models

final class NodeOutputRowNSView: NSView {
    init(_ output: FlowNode.Output) {
        self.output = output
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        nil
    }

    var output: FlowNode.Output

}

#endif
