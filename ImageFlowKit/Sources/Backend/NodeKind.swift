@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Foundation
import Values

public enum NodeKind: Sendable, Hashable, Codable {
    case math(MathNodeKind)
    case valueNode(ValueType)
    case splitValue(SplitValueNodeKind)
    case valueCustomNode(ValueCustomNodeKind)
    case passthroughNode(ValueType)
    case coreImageFilterNode(CIFilterNodeKind)
    case coreImageCustomNode(CoreImageCustomNodeKind)
}

public enum MathNodeKind: Sendable, Hashable, Codable {
    case addNode(NumericValueType)
    case subNode(NumericValueType)
    case mulNode(NumericValueType)

    public static var allCases: [Self] {
        NumericValueType.allCases.flatMap {
            [
                .addNode($0),
                .subNode($0),
                .mulNode($0),
            ]
        }
    }

    public var impl: NodeImpl {
        switch self {
        case .addNode(let type): Nodes.AddNode.impl(type)
        case .subNode(let type): Nodes.SubtractNode.impl(type)
        case .mulNode(let type): Nodes.MulNode.impl(type)
        }
    }
}

public enum SplitValueNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case vector2
    case vector3
    case vector4
    case color4
    case rect
    case imageInfo

    public var impl: NodeImpl {
        switch self {
        case .vector2:
            Nodes.SplitValueNodes.SlipVector2Node.impl()
        case .vector3:
            Nodes.SplitValueNodes.SlipVector3Node.impl()
        case .vector4:
            Nodes.SplitValueNodes.SlipVector4Node.impl()
        case .color4:
            Nodes.SplitValueNodes.SlipColorRGBNode.impl()
        case .imageInfo:
            Nodes.SplitValueNodes.ImageInfoNode.impl()
        case .rect:
            Nodes.SplitValueNodes.SlipRectNode.impl()
        }
    }
}

public enum ValueCustomNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case affineTransform
    case colorRgba

    public var impl: NodeImpl {
        switch self {
        case .affineTransform:
            Nodes.AffineTransformValueNode.impl()
        case .colorRgba:
            Nodes.Color4RGBAValue.impl()
        }
    }
}

public enum CoreImageCustomNodeKind: Sendable, Hashable, Codable {

    case geometryAdjustment(GeometryAdjustment)
    case colorAdjustment(ColorAdjustment)
    case generator(Generator)

    public var kind: NodeKind {
        .coreImageCustomNode(self)
    }

    public enum GeometryAdjustment: Sendable, Hashable, Codable, CaseIterable {
        case applyAffineTransformNode
        case rotateNode
        case scaleNode
        case translateNode

        public static var allKinds: [NodeKind] {
            GeometryAdjustment.allCases.map { .coreImageCustomNode(.geometryAdjustment($0)) }
        }

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

        public static var allKinds: [NodeKind] {
            ColorAdjustment.allCases.map { .coreImageCustomNode(.colorAdjustment($0)) }
        }

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

    public enum Generator: Sendable, Hashable, Codable, CaseIterable {
        case randomGeneratorNode
        case blurredRectangleGeneratorNode
        case blurredRoundedRectangleGeneratorNode
        case roundedRectangleGeneratorNode
        case roundedRectangleStrokeGeneratorNode
        case stripesGeneratorNode
        case checkerboardGeneratorNode
        case starShineGeneratorNode
        case constantColorGeneratorNode

        public static var allKinds: [NodeKind] {
            Generator.allCases.map { .coreImageCustomNode(.generator($0)) }
        }

        public var kind: NodeKind {
            .coreImageCustomNode(.generator(self))
        }

        public var impl: NodeImpl {
            switch self {
            case .randomGeneratorNode:
                Nodes.CoreImageCustom.RandomGeneratorNode.impl()
            case .blurredRectangleGeneratorNode:
                Nodes.CoreImageCustom.BlurredRectangleGeneratorNode.impl()
            case .blurredRoundedRectangleGeneratorNode:
                Nodes.CoreImageCustom.BlurredRoundedRectangleGeneratorNode.impl()
            case .roundedRectangleGeneratorNode:
                Nodes.CoreImageCustom.RoundedRectangleGeneratorNode.impl()
            case .roundedRectangleStrokeGeneratorNode:
                Nodes.CoreImageCustom.RoundedRectangleStrokeGeneratorNode.impl()
            case .stripesGeneratorNode:
                Nodes.CoreImageCustom.StripesGeneratorNode.impl()
            case .checkerboardGeneratorNode:
                Nodes.CoreImageCustom.CheckerboardGeneratorNode.impl()
            case .starShineGeneratorNode:
                Nodes.CoreImageCustom.StarShineGeneratorNode.impl()
            case .constantColorGeneratorNode:
                Nodes.CoreImageCustom.ConstantColorGeneratorNode.impl()
            }
        }
    }

    public var impl: NodeImpl {
        switch self {
        case .colorAdjustment(let kind): kind.impl
        case .geometryAdjustment(let kind): kind.impl
        case .generator(let kind): kind.impl
        }
    }
}

extension NodeKind {
    public var impl: NodeImpl {
        switch self {
        case .math(let kind):
            kind.impl
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
        case .splitValue(let kind):
            kind.impl
        }
    }

    public var schema: NodeSchema {
        self.impl.schema
    }
}
