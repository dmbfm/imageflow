#if canImport(AppKit)

import AppKit
import Models

final class NodeOutputBlockNSView: NSView {
    internal init(_ outputs: [FlowNode.Output]) {
        self.outputs = outputs
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        nil
    }

    var outputs: [FlowNode.Output]

}

#endif
