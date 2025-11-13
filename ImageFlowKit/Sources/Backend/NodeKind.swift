@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Foundation
import Values

public enum NodeKind: Sendable, Hashable, Codable {
    case addNode(NumericValueType)
    case valueNode(ValueType)
    case valueCustomNode(ValueCustomNodeKind)
    case passthroughNode(ValueType)
    case coreImageFilterNode(CIFilterNodeKind)
    case coreImageCustomNode(CoreImageCustomNodeKind)
}

public enum ValueCustomNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case affineTransform

    public var impl: NodeImpl {
        switch self {
        case .affineTransform:
            Nodes.AffineTransformValueNode.impl()
        }
    }
}

public enum CoreImageCustomNodeKind: Sendable, Hashable, Codable {

    case geometryAdjustment(GeometryAdjustment)
    case colorAdjustment(ColorAdjustment)

    public var kind: NodeKind {
        .coreImageCustomNode(self)
    }

    public enum GeometryAdjustment: Sendable, Hashable, Codable, CaseIterable {
        case applyAffineTransformNode
        case rotateNode
        case scaleNode
        case translateNode

        public var kind: NodeKind {
            .coreImageCustomNode(.geometryAdjustment(self))
        }

        public var impl: NodeImpl {
            switch self {
            case .applyAffineTransformNode:
                Nodes.CoreImageCustom.ApplyAffineTransformFilterNode.impl()
            case .rotateNode:
                Nodes.CoreImageCustom.RotateFilterNode.impl()
            case .scaleNode:
                Nodes.CoreImageCustom.ScaleFilterNode.impl()
            case .translateNode:
                Nodes.CoreImageCustom.TranslateFilterNode.impl()
            }
        }
    }

    public enum ColorAdjustment: Sendable, Hashable, Codable, CaseIterable {
        case lutFilterNode

        public var kind: NodeKind {
            .coreImageCustomNode(.colorAdjustment(self))
        }

        public var impl: NodeImpl {
            switch self {
            case .lutFilterNode:
                Nodes.CoreImageCustom.LutFilterNode.impl()
            }
        }
    }

    public var impl: NodeImpl {
        switch self {
        case .colorAdjustment(let kind): kind.impl
        case .geometryAdjustment(let kind): kind.impl
        }
    }
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
        case .coreImageCustomNode(let type):
            type.impl
        case .valueCustomNode(let type):
            type.impl
        }
    }

    public var schema: NodeSchema {
        self.impl.schema
    }
}
