@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Foundation
import Values

public enum NodeKind: Sendable, Hashable, Codable {
    case addNode(NumericValueType)
    case valueNode(ValueType)
    case angleNode
    case passthroughNode(ValueType)
    case blur(BlurType)
}

extension NodeKind {
    public var impl: NodeImpl {
        switch self {
        case .addNode(let type):
            Nodes.AddNode.impl(type)
        case .angleNode:
            Nodes.AngleNode.impl()
        case .valueNode(let type):
            Nodes.ValueNode.impl(type)
        case .passthroughNode(let type):
            Nodes.PassthroughNode.impl(type)
        case .blur(let type):
            type.impl
        }
    }

    public var schema: NodeSchema {
        self.impl.schema
    }
}
