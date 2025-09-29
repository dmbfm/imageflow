@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Foundation

public enum NodeKind: Sendable, Hashable, Codable {
    case addNode(NumericValueType)
    case valueNode(ValueType)
    case passthroughNode(ValueType)
    case coreImageFilterNode(CIFilterNodeKind)
}

extension NodeKind {
    public var impl: NodeImpl {
        switch self {
        case .addNode(let type):
            Nodes.AddNode.impl(type)
        case .valueNode(let type):
            Nodes.ValueNode.impl(type)
        case .passthroughNode(let type):
            Nodes.PassthroughNode.impl(type)
        case .coreImageFilterNode(let type):
            type.impl
        }
    }

    public var schema: NodeSchema {
        self.impl.schema
    }
}
