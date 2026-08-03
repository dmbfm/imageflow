import Backend
import Helpers
import Values

private struct Categories {
    static let boolaenOperations: NodePaletteCategory = .init(
        name: .booleanOperations,
        items: [
            .init(nodeKind: .booleanOperation(.ifNode(.float)), displayName: "If", categoryName: .booleanOperations),
            .init(
                nodeKind: .booleanOperation(.equalNode(.float)),
                displayName: "Equal",
                categoryName: .booleanOperations
            ),
            .init(
                nodeKind: .booleanOperation(.greater(.float)),
                displayName: "Greater Than",
                categoryName: .booleanOperations
            ),
            .init(
                nodeKind: .booleanOperation(.greaterOrEqual(.float)),
                displayName: "Greater Than or Equal",
                categoryName: .booleanOperations
            ),
            .init(
                nodeKind: .booleanOperation(.smaller(.float)),
                displayName: "Less Than",
                categoryName: .booleanOperations
            ),
            .init(
                nodeKind: .booleanOperation(.smallerOrEqual(.float)),
                displayName: "Less Than or Equal",
                categoryName: .booleanOperations
            ),
            .init(nodeKind: .booleanOperation(.andNode), categoryName: .booleanOperations),
            .init(nodeKind: .booleanOperation(.orNode), categoryName: .booleanOperations),
            .init(nodeKind: .booleanOperation(.xorNode), categoryName: .booleanOperations),
            .init(nodeKind: .booleanOperation(.notNode), categoryName: .booleanOperations),
        ]
    )

    static let vectorOperations: NodePaletteCategory = .init(
        name: .vectorOperations,
        items: [
            .init(
                nodeKind: .vectorOperation(.dotProduct(.vector2)),
                displayName: "Dot Product",
                categoryName: .vectorOperations
            ),
            .init(
                nodeKind: .vectorOperation(.pointDistance(.vector2)),
                displayName: "Point Distance",
                categoryName: .vectorOperations
            ),
            .init(
                nodeKind: .vectorOperation(.vectorLength(.vector2)),
                displayName: "Vector Length",
                categoryName: .vectorOperations
            ),
            .init(
                nodeKind: .vectorOperation(.vectorNormalize(.vector2)),
                displayName: "Normalize Vector",
                categoryName: .vectorOperations
            ),
            .init(nodeKind: .vectorOperation(.crossProduct), categoryName: .vectorOperations),
        ]
    )

    static let image: NodePaletteCategory = .init(name: .image, items: [
        .init(nodeKind: .splitValue(.imageSize), categoryName: .image),
        .init(nodeKind: .splitValue(.imageOrigin), categoryName: .image),
        .init(nodeKind: .splitValue(.imageRect), categoryName: .image),
        .init(nodeKind: .splitValue(.imageChannels), categoryName: .image),
        .init(nodeKind: .combineValue(.imageRGB), categoryName: .image),
        .init(nodeKind: .combineValue(.imageRGBA), categoryName: .image),
        // .init(nodeKind: .splitValue(.mas), categoryName: .image),
    ])

    static let mathFunctions: NodePaletteCategory = .init(
        name: .functions,
        items: MathFunctionNodeKind.allKinds.map({ .init(nodeKind: $0, categoryName: .functions) })
        // items: [
        //     .init(nodeKind: .mathFunction(.sinNode), categoryName: .functions),
        //     .init(nodeKind: .mathFunction(.cosNode), categoryName: .functions),
        //     .init(nodeKind: .mathFunction(.tanNode), categoryName: .functions),
        //     .init(nodeKind: .mathFunction(.log2), categoryName: .functions),
        //     .init(nodeKind: .mathFunction(.log10), categoryName: .functions),
        //     .init(nodeKind: .mathFunction(.pow), categoryName: .functions),
        // ]
    )

    static let math: NodePaletteCategory = .init(
        name: .math,
        items: [
            .init(
                displayName: "Add",
                icon: NodeKind.math(.addNode(.float)).icon,
                nodeKind: NodeKind.math(.addNode(.float)),
                categoryName: .math
            ),
            .init(
                displayName: "Subtract",
                icon: NodeKind.math(.subNode(.float)).icon,
                nodeKind: NodeKind.math(.subNode(.float)),
                categoryName: .math
            ),
            .init(
                displayName: "Multiply",
                icon: NodeKind.math(.mulNode(.float)).icon,
                nodeKind: NodeKind.math(.mulNode(.float)),
                categoryName: .math
            ),
            .init(
                displayName: "Divide",
                icon: NodeKind.math(.divNode(.float)).icon,
                nodeKind: NodeKind.math(.divNode(.float)),
                categoryName: .math
            ),
        ]
    )

    static let input: NodePaletteCategory =
        .init(
            name: .input,
            items: ValueType.allCases
                .excluding(
                    elementsOf: [
                        .data,
                        .floatArray,
                        .attributedString,
                        .colorSpace,
                        .lut,
                    ]
                )
                .map { NodeKind.valueNode($0) }
                .map { kind in
                    return NodePaletteItem(
                        nodeKind: kind,
                        categoryName: .input
                    )
                }
        )

    static let split: NodePaletteCategory =
        .init(
            name: .split,
            items: SplitValueNodeKind.allCases
                .excluding(elementsOf: [.imageRect, .imageSize, .imageOrigin, .imageChannels])
                .map({ NodeKind.splitValue($0) })
                .map { .init(nodeKind: $0, categoryName: .split) }
        )

    static let combine: NodePaletteCategory =
        .init(
            name: .combine,
            items: CombineValueNodeKind.allCases
                .excluding(elementsOf: [.imageRGB, .imageRGBA])
                .map({ NodeKind.combineValue($0) })
                .map { .init(nodeKind: $0, categoryName: .combine) }
        )

    static let imageTransform: NodePaletteCategory =
        .init(
            name: .imageTransform,
            items: ImageTransformNodeKind.allCases
                .map({ NodeKind.imageTransform($0) })
                .map { .init(nodeKind: $0, categoryName: .transform) }
        )

    static let transform: NodePaletteCategory =
        .init(
            name: .transform,
            items: TransformNodeKind.allCases
                .map({ NodeKind.transform($0) })
                .map { .init(nodeKind: $0, categoryName: .transform) }
        )

    static let blur: NodePaletteCategory = .init(
        name: .blur,
        items: CIFilterNodeKind.BlurNodeKind.allCases
            .excluding(elementsOf: [
                .CIMorphologyGradient, .CIMorphologyMaximum, .CIMorphologyMinimum, .CIMorphologyGradient,
                .CIMorphologyRectangleMaximum, .CIMorphologyRectangleMinimum,
            ])
            .map { NodeKind.coreImageFilterNode(.blur($0)) }
            .map { kind in
                return NodePaletteItem(
                    nodeKind: kind,
                    categoryName: .blur
                )
            }
    )

    static let colorAdjustment: NodePaletteCategory =
        .init(
            name: .colorAdjustment,
            items: CIFilterNodeKind.ColoradjustmentNodeKind.allCases
                .excluding(elementsOf: [.CIDisparityToDepth, .CIDepthToDisparity])
                .map { NodeKind.coreImageFilterNode(.colorAdjustment($0)) }
                .appending(elementsOf: CoreImageCustomNodeKind.ColorAdjustment.allKinds)
                .map { kind in
                    .init(nodeKind: kind, categoryName: .colorAdjustment)
                }
        )

    static let colorEffect: NodePaletteCategory =
        .init(
            name: .colorEffect,
            items: CIFilterNodeKind.ColoreffectNodeKind.allCases
                .excluding(elementsOf: [.CIColorMap, .CIColorPosterize, .CILabDeltaE, .CIVignetteEffect, .CIPalettize])
                .map { NodeKind.coreImageFilterNode(.colorEffect($0)) }
                .appending(elementsOf: CoreImageCustomNodeKind.ColorEffect.allKinds)
                .map { NodePaletteItem(nodeKind: $0, categoryName: .colorEffect) }
        )

    static let compositeOperation: NodePaletteCategory =
        .init(
            name: .compositeOperation,
            // items: CIFilterNodeKind.CompositeoperationNodeKind.allCases
            //     .map { NodeKind.coreImageFilterNode(.compositeOperation($0)) }
            items: CompositeOperationNodeKind.allKinds
                .appending(elementsOf: [
                    .coreImageFilterNode(.stylize(.CIMix))
                    // .coreImageFilterNode(.stylize(.CIBlendWithMask)),
                    // .coreImageFilterNode(.stylize(.CIBlendWithRedMask)),
                    // .coreImageFilterNode(.stylize(.CIBlendWithBlueMask)),
                    // .coreImageFilterNode(.stylize(.CIBlendWithAlphaMask)),
                ])
                .map { NodePaletteItem(nodeKind: $0, categoryName: .compositeOperation) }
        )

    static let distortionEffect: NodePaletteCategory =
        .init(
            name: .distortionEffect,
            items: CIFilterNodeKind.DistortioneffectNodeKind.allCases
                .excluding(elementsOf: [
                    .CICircleSplashDistortion, .CICircularWrap, .CIDroste, .CIGlassLozenge, .CINinePartStretched,
                    .CINinePartTiled, .CIPinchDistortion,
                ])
                .map { NodeKind.coreImageFilterNode(.distortionEffect($0)) }
                // .appending(elementsOf: CoreImageCustomNodeKind.Distortion.allKinds)
                .map { NodePaletteItem(nodeKind: $0, categoryName: .distortionEffect) }
        )

    static let generator: NodePaletteCategory =
        .init(
            name: .generator,
            items: CIFilterNodeKind.GeneratorNodeKind.allCases
                .excluding(elementsOf: [
                    CIFilterNodeKind.GeneratorNodeKind.CIBlurredRectangleGenerator,
                    .CIRandomGenerator,
                    .CIBlurredRoundedRectangleGenerator,
                    .CIRoundedRectangleGenerator,
                    .CIRoundedRectangleStrokeGenerator,
                    .CIStripesGenerator,
                    .CICheckerboardGenerator,
                    .CIStarShineGenerator,
                    .CIConstantColorGenerator,
                ]
                )
                .map { NodeKind.coreImageFilterNode(.generator($0)) }
                .appending(elementsOf: CoreImageCustomNodeKind.Generator.allKinds)
                .map { NodePaletteItem(nodeKind: $0, categoryName: .generator) }
        )

    static let geometryAdjustment: NodePaletteCategory =
        .init(
            name: .geometryAdjustment,
            items: CIFilterNodeKind.GeometryadjustmentNodeKind.allCases
                .excluding(elementsOf: [
                    .CIAffineTransform, .CIBicubicScaleTransform, .CIKeystoneCorrectionCombined,
                    .CIEdgePreserveUpsampleFilter, .CIKeystoneCorrectionHorizontal, .CIPerspectiveCorrection,
                    .CIPerspectiveRotate, .CIPerspectiveTransform, .CIPerspectiveTransformWithExtent,
                    .CIKeystoneCorrectionVertical,
                ])
                .map { NodeKind.coreImageFilterNode(.geometryAdjustment($0)) }
                // .appending(elementsOf: CoreImageCustomNodeKind.GeometryAdjustment.allKinds)
                .map { NodePaletteItem(nodeKind: $0, categoryName: .geometryAdjustment) }
        )

    static let gradient: NodePaletteCategory =
        .init(
            name: .gradient,
            items: CIFilterNodeKind.GradientNodeKind.allCases
                .filter({
                    ![
                        CIFilterNodeKind.GradientNodeKind.CIRadialGradient,
                        CIFilterNodeKind.GradientNodeKind.CIGaussianGradient,
                        CIFilterNodeKind.GradientNodeKind.CIDistanceGradientFromRedMask,
                        CIFilterNodeKind.GradientNodeKind.CISignedDistanceGradientFromRedMask,
                        CIFilterNodeKind.GradientNodeKind.CILinearGradient,
                        CIFilterNodeKind.GradientNodeKind.CISmoothLinearGradient,
                        CIFilterNodeKind.GradientNodeKind.CIRadialGradient,
                    ].contains($0)
                })
                .map { NodeKind.coreImageFilterNode(.gradient($0)) }
                .appending(elementsOf: CoreImageCustomNodeKind.Gradient.allKinds)
                .map { NodePaletteItem(nodeKind: $0, categoryName: .gradient) }
        )

    static let halftone: NodePaletteCategory =
        .init(
            name: .halftoneEffect,
            items: CIFilterNodeKind.HalftoneeffectNodeKind.allCases
                .map { NodeKind.coreImageFilterNode(.halftoneEffect($0)) }
                .map { NodePaletteItem(nodeKind: $0, categoryName: .halftoneEffect) }
        )

    static let reduction: NodePaletteCategory =
        .init(
            name: .reduction,
            items: CIFilterNodeKind.ReductionNodeKind.allCases
                .excluding(elementsOf: [
                    .CIKMeans,
                    .CIAreaHistogram,
                    .CIAreaLogarithmicHistogram,
                    .CIAreaAlphaWeightedHistogram,
                    .CIHistogramDisplayFilter,
                ])
                .map { NodeKind.coreImageFilterNode(.reduction($0)) }
                .appending(elementsOf: CoreImageCustomNodeKind.Reduction.allKinds)
                .map { NodePaletteItem(nodeKind: $0, categoryName: .reduction) }
        )

    static let sharpen: NodePaletteCategory =
        .init(
            name: .sharpen,
            items: CIFilterNodeKind.SharpenNodeKind.allCases
                .map { NodeKind.coreImageFilterNode(.sharpen($0)) }
                .map { NodePaletteItem(nodeKind: $0, categoryName: .sharpen) }
        )

    static let stylize: NodePaletteCategory =
        .init(
            name: .stylize,
            items: CIFilterNodeKind.StylizeNodeKind.allCases
                .excluding(elementsOf: [
                    .CIConvolution3X3, .CIConvolution5X5, .CIConvolution7X7, .CIConvolutionRGB3X3, .CIConvolutionRGB5X5,
                    .CIConvolutionRGB7X7, .CIConvolution9Vertical, .CIConvolution9Horizontal,
                    .CIConvolutionRGB9Vertical, .CIConvolutionRGB9Horizontal, .CIHeightFieldFromMask, .CIMix,
                    .CIBlendWithMask, .CIBlendWithRedMask, .CIBlendWithBlueMask, .CIBlendWithAlphaMask,
                ])
                .map { NodeKind.coreImageFilterNode(.stylize($0)) }
                .map { NodePaletteItem(nodeKind: $0, categoryName: .stylize) }
        )

    static let tileEffect: NodePaletteCategory =
        .init(
            name: .tileEffect,
            items: TileEffectNodeKind.allKinds
                .map({ .init(nodeKind: $0, categoryName: .tileEffect) })
            // items: CIFilterNodeKind.TileeffectNodeKind.allCases
            //     .excluding(elementsOf: [.CIAffineClamp])
            //     .map { NodeKind.coreImageFilterNode(.tileEffect($0)) }
            //     .appending(elementsOf: TileEffectNodeKind.allKinds)
            //     .map { NodePaletteItem(nodeKind: $0, categoryName: .tileEffect) }
        )

    static let transition: NodePaletteCategory =
        .init(
            name: .transition,
            items: CIFilterNodeKind.TransitionNodeKind.allCases
                .map { NodeKind.coreImageFilterNode(.transition($0)) }
                .map { NodePaletteItem(nodeKind: $0, categoryName: .transition) }
        )

    static let video: NodePaletteCategory =
        .init(
            name: .video,
            items: CIFilterNodeKind.VideoNodeKind.allCases
                .map { NodeKind.coreImageFilterNode(.video($0)) }
                .map { NodePaletteItem(nodeKind: $0, categoryName: .video) }
        )

    static let segmentation: NodePaletteCategory =
        .init(
            name: .segmentation,
            items: CoreImageCustomNodeKind.Segmentation.allKinds
                .map { NodePaletteItem(nodeKind: $0, categoryName: .segmentation) }
        )

    static let convolution: NodePaletteCategory =
        .init(
            name: .convolution,
            items: CoreImageCustomNodeKind.Convolution.allKinds
                .map { NodePaletteItem(nodeKind: $0, categoryName: .convolution) }
        )
}

@MainActor
public class NodePaletteService {

    lazy var allItems: [NodePaletteItem] = {
        var result = [NodePaletteItem]()

        for cat in self.categories() {
            result.append(contentsOf: cat.items)
        }

        return result
    }()

    lazy var categories: [NodePaletteCategory] = {

        var result = [NodePaletteCategory]()

        result.append(Categories.input)
        result.append(Categories.image)
        result.append(Categories.blur)
        result.append(Categories.colorAdjustment)
        result.append(Categories.colorEffect)
        result.append(Categories.compositeOperation)
        result.append(Categories.distortionEffect)
        result.append(Categories.imageTransform)
        result.append(Categories.transform)
        result.append(Categories.geometryAdjustment)
        result.append(Categories.generator)
        result.append(Categories.gradient)
        result.append(Categories.halftone)
        result.append(Categories.reduction)
        result.append(Categories.sharpen)
        result.append(Categories.stylize)
        result.append(Categories.segmentation)
        result.append(Categories.convolution)
        result.append(Categories.tileEffect)
        result.append(Categories.split)
        result.append(Categories.combine)
        result.append(Categories.math)
        result.append(Categories.boolaenOperations)
        result.append(Categories.vectorOperations)
        result.append(Categories.mathFunctions)
        // result.append(Categories.transition)
        // result.append(Categories.video)

        return
            result
            .map { cat in
                NodePaletteCategory(
                    name: cat.name,
                    items: cat.items.sorted(by: { $0.displayName < $1.displayName })
                )
            }
    }()

    public init() {}

    public static let shared: NodePaletteService = .init()

    public func categories(
        connectingToType type: ValueType,
        direction: PortDirection,
        searchText: String = ""
    ) -> [NodePaletteCategory] {
        var result: [NodePaletteCategory] = []

        let text = searchText.lowercased()

        for cat in self.categories {
            var items: [NodePaletteItem] = []
            for item in cat.items {
                if let variation = item.variationThatcanConnectToPort(ofType: type, direction: direction),
                    searchText.isEmpty || variation.displayName.lowercased().contains(text)
                {
                    items.append(variation)
                }
            }
            if !items.isEmpty {
                var c = cat
                c.items = items
                result.append(c)
            }
        }

        return result
    }

    public func categories(searchText: String = "") -> [NodePaletteCategory] {
        if searchText.isEmpty {
            return self.categories
        } else {
            return self.categories.map { cat in
                var r = cat
                r.items = cat.items.filter { item in
                    item.displayName.lowercased().contains(searchText.lowercased())
                }
                return r
            }.filter({ !$0.items.isEmpty })
        }
    }

    public func items(searchText: String = "", typedPort: TypedPortLocation? = nil) -> [NodePaletteItem] {
        let items =
            if let typedPort {
                switch typedPort.port.slot {
                case .input(_):
                    self.items(connectingToInputOfType: typedPort.type)
                case .output(_):
                    self.items(connectingToOutputOfType: typedPort.type)
                }
            } else {
                self.allItems
            }

        if searchText.isEmpty {
            return items
        } else {
            return items.filter { entry in
                let text = searchText.lowercased()
                return entry.categoryName.rawValue.lowercased().contains(text)
                    || entry.displayName.lowercased().contains(text)
            }
        }
    }

    public func items(connectingToInputOfType type: ValueType) -> [NodePaletteItem] {
        self.items(connectingTo: type, isInput: true)
    }

    public func items(connectingToOutputOfType type: ValueType) -> [NodePaletteItem] {
        self.items(connectingTo: type, isInput: false)
    }

    private func items(connectingTo type: ValueType, isInput: Bool) -> [NodePaletteItem] {
        var result: [NodePaletteItem] = []

        for item in self.allItems {
            outer: for v in item.nodeKind.variations {
                let schema = v.schema

                if isInput {
                    for output in schema.outputs where output.type == type {
                        result.append(item.with(\.nodeKind, v))
                        break outer
                    }
                } else {
                    for input in schema.inputs where input.type == type {
                        result.append(item.with(\.nodeKind, v))
                        break outer
                    }
                }
            }
        }

        return result
    }
}

public enum NodePaletteCategoryName: String, Sendable, Hashable, Identifiable {
    case input = "Input"
    case math = "Math Operations"
    case functions = "Math Functions"
    case booleanOperations = "Boolean Operations"
    case image = "Image"
    case vectorOperations = "Vector Operations"
    case blur = "Blur"
    case split = "Split"
    case combine = "Combine"
    case imageTransform = "Transform Image"
    case transform = "Affine Transforms"
    case colorAdjustment = "Color Adjustment"
    case colorEffect = "Color Effect"
    case compositeOperation = "Composite Operation"
    case distortionEffect = "Distortion"
    case generator = "Generator"
    case geometryAdjustment = "Geometry Adjustment"
    case gradient = "Gradient"
    case halftoneEffect = "Halftone"
    case reduction = "Color Reduction"
    case sharpen = "Sharpen"
    case stylize = "Stylize"
    case segmentation = "Segmentation"
    case tileEffect = "Tile Effect"
    case transition = "Transition"
    case video = "Video"
    case convolution = "Convolution"

    public var id: Self { self }
}

public struct NodePaletteCategory: Sendable, Hashable, Identifiable {
    public var name: NodePaletteCategoryName
    public var items: [NodePaletteItem]

    public var id: NodePaletteCategoryName { self.name }
}

public struct NodePaletteItem: Sendable, Hashable, Identifiable, With {
    public var displayName: String
    public var icon: String
    public var nodeKind: NodeKind
    public var categoryName: NodePaletteCategoryName

    public var id: Self { self }

    public init(nodeKind: NodeKind, displayName: String? = nil, categoryName: NodePaletteCategoryName) {
        self.init(
            displayName: displayName ?? nodeKind.displayName,
            icon: nodeKind.icon,
            nodeKind: nodeKind,
            categoryName: categoryName
        )
    }

    public init(displayName: String, icon: String, nodeKind: NodeKind, categoryName: NodePaletteCategoryName) {
        self.displayName = displayName
        self.icon = icon
        self.nodeKind = nodeKind
        self.categoryName = categoryName
    }

}

extension NodePaletteItem {
    func canConnectToPort(ofType type: ValueType, direction: PortDirection) -> Bool {
        if direction == .input {
            for output in self.nodeKind.schema.outputs where output.type == type {
                return true
            }
        } else {
            for input in self.nodeKind.schema.inputs where input.type == type {
                return true
            }
        }

        return false
    }

    func variationThatcanConnectToPort(ofType type: ValueType, direction: PortDirection) -> NodePaletteItem? {
        for variation in self.nodeKind.variations {
            let schema = variation.schema
            if direction == .input {
                for output in schema.outputs where output.type == type {
                    return self.with(\.nodeKind, variation)
                }
            } else {
                for input in schema.inputs where input.type == type {
                    return self.with(\.nodeKind, variation)
                }
            }
        }

        return nil
    }
}
