@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Foundation
import Values

public enum NodeKind: Sendable, Hashable, Codable {
    case math(MathNodeKind)
    case mathFunction(MathFunctionNodeKind)
    case booleanOperation(BooleanOperation)
    case vectorOperation(VectorOperationNodeKind)
    case valueNode(ValueType)
    case splitValue(SplitValueNodeKind)
    case combineValue(CombineValueNodeKind)
    case imageTransform(ImageTransformNodeKind)
    case transform(TransformNodeKind)
    case tileEffect(TileEffectNodeKind)
    case passthroughNode(ValueType)
    case compositeOperation(CompositeOperationNodeKind)
    case coreImageFilterNode(CIFilterNodeKind)
    case coreImageCustomNode(CoreImageCustomNodeKind)
    case experimental(ExperimentalNodeKind)
    case stylize(StylizeNodeKind)
}

public enum ExperimentalNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case resize
    case resizeToWidth
    case resizeToHeight

    public static var allKinds: [NodeKind] {
        ExperimentalNodeKind.allCases.map({ .experimental($0) })
    }

    public var impl: NodeImpl {
        switch self {
        case .resizeToWidth:
            Nodes.Experimental.resizeToWidth
        case .resizeToHeight:
            Nodes.Experimental.resizeToHeight
        case .resize:
            Nodes.Experimental.resize
        }
    }
}

public enum StylizeNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case edges3d

    public static var allKinds: [NodeKind] {
        StylizeNodeKind.allCases.map({ .stylize($0) })
    }

    public var impl: NodeImpl {
        switch self {
        case .edges3d:
            Nodes.Stylize.edges3D
        }
    }
}

public enum VectorOperationNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case dotProduct(VectorValueType)
    case crossProduct
    case pointDistance(VectorValueType)
    case vectorLength(VectorValueType)
    case vectorNormalize(VectorValueType)

    public static let allCases: [VectorOperationNodeKind] =
        VectorValueType.allCases.map({ .dotProduct($0) }) + [.crossProduct]

    public static var allKinds: [NodeKind] {
        VectorOperationNodeKind.allCases.map({ .vectorOperation($0) })
    }

    public var impl: NodeImpl {
        switch self {
        case .crossProduct:
            Nodes.vectorCrossNodeImpl
        case .dotProduct(let type):
            Nodes.vectorDotNodeImpl(type)
        case .pointDistance(let type):
            Nodes.vectorDistanceNodeImpl(type)
        case .vectorLength(let type):
            Nodes.vectorLengthNodeImpl(type)
        case .vectorNormalize(let type):
            Nodes.vectorNormalizeNodeImpl(type)
        }
    }
}

public enum BooleanOperation: Sendable, Hashable, Codable {
    case ifNode(ValueType)
    case equalNode(ValueType)
    case greater(NumericComparableValueType)
    case greaterOrEqual(NumericComparableValueType)
    case smaller(NumericComparableValueType)
    case smallerOrEqual(NumericComparableValueType)
    case andNode
    case orNode
    case xorNode
    case notNode

    // public static var allKinds: [NodeKind] {
    //     [
    //         .booleanOperation(.ifNode(ValueType))
    //     ]
    // }

    public var kind: NodeKind {
        .booleanOperation(self)
    }

    public var impl: NodeImpl {
        switch self {
        case .ifNode(let type):
            Nodes.BooleanOperations.IfNode.impl(type)
        case .equalNode(let type):
            Nodes.BooleanOperations.equalNodeImpl(type)
        case .andNode:
            Nodes.BooleanOperations.AndNode.impl()
        case .orNode:
            Nodes.BooleanOperations.OrNode.impl()
        case .xorNode:
            Nodes.BooleanOperations.XorNode.impl()
        case .notNode:
            Nodes.BooleanOperations.NotNode.impl()
        case .greater(let type):
            Nodes.BooleanOperations.greaterThanNodeImpl(type)
        case .greaterOrEqual(let type):
            Nodes.BooleanOperations.greaterOrEqualThanNodeImpl(type)
        case .smaller(let type):
            Nodes.BooleanOperations.smallerThanNodeImpl(type)
        case .smallerOrEqual(let type):
            Nodes.BooleanOperations.smallerOrEqualThanNodeImpl(type)
        }
    }
}

public enum MathFunctionNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case sinNode
    case asinNode
    case cosNode
    case acosNode
    case tanNode
    case atanNode
    case atan2Node
    case log2Node
    case log10Node
    case powNode
    case abs
    case frac
    case truncate
    case max
    case min
    case roundNode
    case floorNode
    case ceilNode
    case signNode
    case clampNode

    public static var allKinds: [NodeKind] {
        MathFunctionNodeKind.allCases.map({ .mathFunction($0) })
    }

    public var kind: NodeKind {
        .mathFunction(self)
    }

    public var impl: NodeImpl {
        switch self {
        case .sinNode:
            Nodes.MathFunctions.floatFunc1NodeImpl("Sin", sema: .float(.angle(nil)), f: { sin($0) })
        case .asinNode:
            Nodes.MathFunctions.floatFunc1NodeImpl("Asin", f: { asin($0) })
        case .cosNode:
            Nodes.MathFunctions.floatFunc1NodeImpl("Cos", sema: .float(.angle(nil)), f: { cos($0) })
        case .acosNode:
            Nodes.MathFunctions.floatFunc1NodeImpl("Acos", f: { acos($0) })
        case .tanNode:
            Nodes.MathFunctions.floatFunc1NodeImpl("Tan", sema: .float(.angle(nil)), f: { tan($0) })
        case .atanNode:
            Nodes.MathFunctions.floatFunc1NodeImpl("Atan", f: { atan($0) })
        case .atan2Node:
            Nodes.MathFunctions.floatFunc2NodeImpl("Atan2", f: { atan2($0, $1) })
        case .log2Node:
            Nodes.MathFunctions.floatFunc1NodeImpl("Log2", f: { log2($0) })
        case .log10Node:
            Nodes.MathFunctions.floatFunc1NodeImpl("Log10", f: { log10($0) })
        case .powNode:
            Nodes.MathFunctions.floatFunc2NodeImpl("Pow", defaultValue1: 2.0, defaultValue2: 2.0, f: { pow($0, $1) })
        case .abs:
            Nodes.MathFunctions.floatFunc1NodeImpl("Abs", f: { Swift::abs($0) })
        case .frac:
            Nodes.MathFunctions.floatFunc1NodeImpl("Frac", f: { $0.truncatingRemainder(dividingBy: 1.0) })
        case .truncate:
            Nodes.MathFunctions.floatFunc1NodeImpl("Truncate", f: { trunc($0) })
        case .max:
            Nodes.MathFunctions.floatFunc2NodeImpl(
                "Max",
                defaultValue1: 1.0,
                defaultValue2: 2.0,
                f: {
                    Swift::max($0, $1)
                }
            )
        case .min:
            Nodes.MathFunctions.floatFunc2NodeImpl(
                "Min",
                defaultValue1: 1.0,
                defaultValue2: 2.0,
                f: {
                    Swift::min($0, $1)
                }
            )
        case .roundNode:
            Nodes.MathFunctions.floatFunc1NodeImpl("Round", f: { $0.rounded() })
        case .floorNode:
            Nodes.MathFunctions.floatFunc1NodeImpl("Floor", f: { floor($0) })
        case .ceilNode:
            Nodes.MathFunctions.floatFunc1NodeImpl("Ceil", f: { ceil($0) })
        case .signNode:
            Nodes.MathFunctions.floatFunc1NodeImpl(
                "Sign",
                defaultValue: -1.0,
                f: { $0 == 0.0 ? 0.0 : ($0 < 0 ? -1.0 : 1.0) }
            )
        case .clampNode:
            Nodes.MathFunctions.floatFunc3NodeImpl(
                "Clamp",
                arg1: "Value",
                defaultValue1: 10.0,
                arg2: "Min",
                defaultValue2: 0.0,
                arg3: "Max",
                defaultValue3: 1.0,
                f: { x, lo, hi in
                    let _lo = Swift::min(lo, hi)
                    let _hi = Swift::max(lo, hi)
                    return Swift::min(_hi, Swift::max(_lo, x))
                }
            )
        }
    }
}

public enum MathNodeKind: Sendable, Hashable, Codable {
    case addNode(NumericValueType)
    case subNode(NumericValueType)
    case mulNode(NumericValueType)
    case divNode(NumericDivValueType)

    public static var allCases: [Self] {
        NumericValueType.allCases.flatMap {
            [
                .addNode($0),
                .subNode($0),
                .mulNode($0),
            ]
                + NumericDivValueType.allCases.flatMap {
                    [
                        .divNode($0)
                    ]
                }
        }
    }

    public var impl: NodeImpl {
        switch self {
        case .addNode(let type): Nodes.AddNode.impl(type)
        case .subNode(let type): Nodes.SubtractNode.impl(type)
        case .mulNode(let type): Nodes.MulNode.impl(type)
        case .divNode(let type): Nodes.DivNode.impl(type)
        }
    }
}

public enum CompositeOperationNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case blendNode
    case blendMaskNode
    case setAlphaToOne

    public static var allKinds: [NodeKind] {
        CompositeOperationNodeKind.allCases.map({ .compositeOperation($0) })
    }

    public var kind: NodeKind {
        .compositeOperation(self)
    }

    public var impl: NodeImpl {
        switch self {
        case .blendNode:
            Nodes.CoreImageCustom.BlendNode.impl()
        case .blendMaskNode:
            Nodes.CoreImageCustom.BlendWithMask.impl()
        case .setAlphaToOne:
            Nodes.CoreImageCustom.AlphaToOneNode.impl()
        }
    }
}

public enum TileEffectNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case tile
    case affineTile
    case eightfoldReflectedTile
    case fourfoldReflectedTile
    case fourfoldRotatedTile
    case fourfoldTranslatedTile
    case kaleidoscope
    case opTile
    case parallelogramTile
    case sixfoldReflected
    case sixfoldRotated
    case triangleTile
    case twelvefoldReflectedTile

    public static var allKinds: [NodeKind] {
        TileEffectNodeKind.allCases.map({ .tileEffect($0) })
    }

    public var kind: NodeKind {
        .tileEffect(self)
    }

    public var impl: NodeImpl {
        switch self {
        case .tile:
            Nodes.TileEffectNodes.TileNode.impl()
        case .affineTile:
            Nodes.TileEffectNodes.AffineTileNode.impl()
        case .eightfoldReflectedTile:
            Nodes.TileEffectNodes.EightfoldReflectedTileNode.impl()
        case .fourfoldReflectedTile:
            Nodes.TileEffectNodes.FourfoldReflectedTileNode.impl()
        case .fourfoldRotatedTile:
            Nodes.TileEffectNodes.FourfoldRotatedTileNode.impl()
        case .fourfoldTranslatedTile:
            Nodes.TileEffectNodes.FourfoldTranslatedTileNode.impl()
        case .kaleidoscope:
            Nodes.TileEffectNodes.KaleidoscopeNode.impl()
        case .opTile:
            Nodes.TileEffectNodes.OpTileNode.impl()
        case .parallelogramTile:
            Nodes.TileEffectNodes.ParallelogramTileNode.impl()
        case .sixfoldReflected:
            Nodes.TileEffectNodes.SixfoldReflectedTileNode.impl()
        case .sixfoldRotated:
            Nodes.TileEffectNodes.SixfoldRotatedTileNode.impl()
        case .triangleTile:
            Nodes.TileEffectNodes.TriangleTileNode.impl()
        case .twelvefoldReflectedTile:
            Nodes.TileEffectNodes.TwelvefoldReflectedTileNode.impl()
        }
    }
}

public enum TransformNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case rotate
    case scale
    case scaleUniform
    case translate
    case srt

    public var impl: NodeImpl {
        switch self {
        case .rotate:
            Nodes.TransformNodes.TransformRotate.impl()
        case .scale:
            Nodes.TransformNodes.TransformScale.impl()
        case .scaleUniform:
            Nodes.TransformNodes.TransformScaleUniform.impl()
        case .translate:
            Nodes.TransformNodes.TransformTranslate.impl()
        case .srt:
            Nodes.TransformNodes.TransformSRT.impl()
        }
    }
}

public enum ImageTransformNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case rotate
    case scale
    case scaleUniform
    case translate
    case applyAffineTransform

    public static var allKinds: [NodeKind] {
        ImageTransformNodeKind.allCases.map({ .imageTransform($0) })
    }

    public var kind: NodeKind {
        .imageTransform(self)
    }

    public var impl: NodeImpl {
        switch self {
        case .rotate:
            Nodes.CoreImageCustom.RotateFilterNode.impl()
        case .scale:
            Nodes.CoreImageCustom.ScaleFilterNode.impl()
        case .scaleUniform:
            Nodes.CoreImageCustom.ScaleUniformFilterNode.impl()
        case .translate:
            Nodes.CoreImageCustom.TranslateFilterNode.impl()
        case .applyAffineTransform:
            Nodes.CoreImageCustom.ApplyAffineTransformFilterNode.impl()
        }
    }
}

public enum SplitValueNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case vector2
    case vector3
    case vector4
    case color4
    case rect
    case imageSize
    case imageRect
    case imageOrigin
    case imageChannels

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
        case .imageSize:
            Nodes.SplitValueNodes.ImageSizeNode.impl()
        case .imageRect:
            Nodes.SplitValueNodes.ImageRectNode.impl()
        case .imageOrigin:
            Nodes.SplitValueNodes.ImageOriginNode.impl()
        case .imageChannels:
            Nodes.SplitValueNodes.ImageChannelsNode.impl()
        case .rect:
            Nodes.SplitValueNodes.SlipRectNode.impl()
        }
    }
}

public enum CombineValueNodeKind: Sendable, Hashable, Codable, CaseIterable {
    case affineTransform
    case vector2
    case vector3
    case vector4
    case color4
    case rect
    case imageRGB
    case imageRGBA

    public var impl: NodeImpl {
        switch self {
        case .affineTransform:
            Nodes.CombineValueNodes.CombineAffineTransformNode.impl()
        case .vector2:
            Nodes.CombineValueNodes.CombineVector2Node.impl()
        case .vector3:
            Nodes.CombineValueNodes.CombineVector3Node.impl()
        case .vector4:
            Nodes.CombineValueNodes.CombineVector4Node.impl()
        case .color4:
            Nodes.CombineValueNodes.CombineColor4Node.impl()
        case .rect:
            Nodes.CombineValueNodes.CombineRectNode.impl()
        case .imageRGB:
            Nodes.CombineValueNodes.CombineImageRGB.impl()
        case .imageRGBA:
            Nodes.CombineValueNodes.CombineImageRGBA.impl()
        }
    }
}

public enum CoreImageCustomNodeKind: Sendable, Hashable, Codable {
    case colorAdjustment(ColorAdjustment)
    case colorEffect(ColorEffect)
    case generator(Generator)
    case segmentation(Segmentation)
    case convolution(Convolution)
    case reduction(Reduction)
    case gradient(Gradient)
    case distortion(Distortion)
    case geometry(GeometryAdjustment)

    public var kind: NodeKind {
        .coreImageCustomNode(self)
    }

    public enum GeometryAdjustment: Sendable, Hashable, Codable, CaseIterable {
        case crop

        public static var allKinds: [NodeKind] {
            GeometryAdjustment.allCases.map({ .coreImageCustomNode(.geometry($0)) })
        }

        public var kind: NodeKind {
            .coreImageCustomNode(.geometry(self))
        }

        public var impl: NodeImpl {
            switch self {
            case .crop:
                Nodes.CoreImageCustom.cropNodeImpl
            }
        }
    }

    public enum Distortion: Sendable, Hashable, Codable, CaseIterable {
        case droste

        public static var allKinds: [NodeKind] {
            Distortion.allCases.map({ .coreImageCustomNode(.distortion($0)) })
        }

        public var kind: NodeKind {
            .coreImageCustomNode(.distortion(self))
        }

        public var impl: NodeImpl {
            switch self {
            case .droste:
                Nodes.CoreImageCustom.DrosteNode.impl()
            }
        }
    }

    public enum Gradient: Sendable, Hashable, Codable, CaseIterable {
        case radialGradient
        case gaussianGradient
        case distanceGradientFromRedMask
        case signedDistanceGradientFromRedMask
        case linearGradient

        public static var allKinds: [NodeKind] {
            Gradient.allCases.map({ .coreImageCustomNode(.gradient($0)) })
        }

        public var kind: NodeKind {
            .coreImageCustomNode(.gradient(self))
        }

        public var impl: NodeImpl {
            switch self {
            case .radialGradient:
                Nodes.CoreImageCustom.RadialGradientNode.impl()
            case .gaussianGradient:
                Nodes.CoreImageCustom.GaussianGradientNode.impl()
            case .distanceGradientFromRedMask:
                Nodes.CoreImageCustom.DistanceGradientFromRedMaskNode.impl()
            case .signedDistanceGradientFromRedMask:
                Nodes.CoreImageCustom.SignedDistanceGradientFromRedMaskNode.impl()
            case .linearGradient:
                Nodes.CoreImageCustom.LinearGradientNode.impl()
            }
        }
    }

    public enum Reduction: Sendable, Hashable, Codable, CaseIterable {
        case kmeans

        public static var allKinds: [NodeKind] {
            [.coreImageCustomNode(.reduction(.kmeans))]
        }

        public var kind: NodeKind {
            .coreImageCustomNode(.reduction(self))
        }

        public var impl: NodeImpl {
            switch self {
            case .kmeans:
                Nodes.CoreImageCustom.KMeansNode.impl()
            }
        }

    }

    public enum ColorEffect: Sendable, Hashable, Codable, CaseIterable {
        case palettizeKMeans
        case palettize
        case colorMap
        case colorPosterize
        case orderedDither
        case grayscale
        case blackAndWhite
        case chromaticAberration

        public static var allKinds: [NodeKind] {
            ColorEffect.allCases.map { .coreImageCustomNode(.colorEffect($0)) }
        }

        public var kind: NodeKind {
            .coreImageCustomNode(.colorEffect(self))
        }

        public var impl: NodeImpl {
            switch self {
            case .palettize:
                Nodes.CoreImageCustom.PalettizeNode.impl()
            case .palettizeKMeans:
                Nodes.CoreImageCustom.PalettizeKMeans.impl()
            case .colorMap:
                Nodes.CoreImageCustom.ColorMapNode.impl()
            case .colorPosterize:
                Nodes.CoreImageCustom.ColorPosterizeNode.impl()
            case .grayscale:
                Nodes.CoreImageCustom.grayscaleNode
            case .blackAndWhite:
                Nodes.CoreImageCustom.blackAndWhite
            case .orderedDither:
                Nodes.ColorEffect.ordererdDither
            case .chromaticAberration:
                Nodes.ColorEffect.chromaticAberration
            }
        }

    }

    public enum Convolution: Sendable, Hashable, Codable, CaseIterable {
        case convolution3x3
        case convolution5x5
        case convolution7x7
        case emboss

        public static var allKinds: [NodeKind] {
            [
                .coreImageCustomNode(.convolution(.convolution3x3)),
                .coreImageCustomNode(.convolution(.convolution5x5)),
                .coreImageCustomNode(.convolution(.convolution7x7)),
                .coreImageCustomNode(.convolution(.emboss)),
            ]
        }

        public var kind: NodeKind {
            .coreImageCustomNode(.convolution(self))
        }

        public var impl: NodeImpl {
            switch self {
            case .convolution3x3:
                Nodes.CoreImageCustom.CIConvolution3X3Node.impl()
            case .convolution5x5:
                Nodes.CoreImageCustom.CIConvolution5x5Node.impl()
            case .convolution7x7:
                Nodes.CoreImageCustom.CIConvolution7x7Node.impl()
            case .emboss:
                Nodes.Convolution.embossNodeImpl
            }
        }
    }

    public enum Segmentation: Sendable, Hashable, Codable, CaseIterable {
        case personSegmentation

        public static var allKinds: [NodeKind] {
            [
                .coreImageCustomNode(.segmentation(.personSegmentation))
            ]
        }

        public var kind: NodeKind {
            .coreImageCustomNode(.segmentation(self))
        }

        public var impl: NodeImpl {
            switch self {
            case .personSegmentation:
                Nodes.CoreImageCustom.PersonSegmentationNode.impl()
            }
        }
    }

    public enum ColorAdjustment: Sendable, Hashable, Codable, CaseIterable {
        // case lutFilterNode
        case colorClamp
        case temperatureAndTint
        case toneMap

        public static var allKinds: [NodeKind] {
            ColorAdjustment.allCases.map { .coreImageCustomNode(.colorAdjustment($0)) }
        }

        public var kind: NodeKind {
            .coreImageCustomNode(.colorAdjustment(self))
        }

        public var impl: NodeImpl {
            switch self {
            // case .lutFilterNode:
            //     Nodes.CoreImageCustom.LutFilterNode.impl()
            case .colorClamp:
                Nodes.CoreImageCustom.ColorClampCustom.impl()
            case .temperatureAndTint:
                Nodes.CoreImageCustom.TemperatureAntTint.impl()
            case .toneMap:
                Nodes.CoreImageCustom.ToneMapNode.impl()
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
        case textGeneratorNode
        case shadedSphere
        case simplexNoise

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
            case .textGeneratorNode:
                Nodes.CoreImageCustom.TextNodes.textGeneratorNode
            case .shadedSphere:
                Nodes.Generator.shadedSphere
            case .simplexNoise:
                Nodes.Generator.simplexNoise
            }
        }
    }

    public var impl: NodeImpl {
        switch self {
        case .distortion(let kind): kind.impl
        case .colorAdjustment(let kind): kind.impl
        case .colorEffect(let kind): kind.impl
        case .generator(let kind): kind.impl
        case .segmentation(let kind): kind.impl
        case .convolution(let kind): kind.impl
        case .reduction(let kind): kind.impl
        case .gradient(let kind): kind.impl
        case .geometry(let kind): kind.impl
        }
    }
}

extension NodeKind {
    public var impl: NodeImpl {
        switch self {
        case .math(let kind):
            kind.impl
        case .mathFunction(let kind):
            kind.impl
        case .valueNode(let type):
            Nodes.ValueNode.impl(type)
        case .passthroughNode(let type):
            Nodes.PassthroughNode.impl(type)
        case .booleanOperation(let kind):
            kind.impl
        case .transform(let type):
            type.impl
        case .coreImageFilterNode(let type):
            type.impl
        case .coreImageCustomNode(let type):
            type.impl
        case .splitValue(let kind):
            kind.impl
        case .combineValue(let kind):
            kind.impl
        case .imageTransform(let kind):
            kind.impl
        case .tileEffect(let kind):
            kind.impl
        case .compositeOperation(let kind):
            kind.impl
        case .vectorOperation(let kind):
            kind.impl
        case .experimental(let kind):
            kind.impl
        case .stylize(let kind):
            kind.impl
        }
    }

    public var schema: NodeSchema {
        self.impl.schema
    }
}
