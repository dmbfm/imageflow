import Backend
import Helpers
import Values

private struct Categories {
    static let math: NodePaletteCategory = .init(
        name: .math,
        items: [
            .init(
                nodeKind: .addNode(.float),
                categoryName: .math
            )
        ]
    )

    static let input: NodePaletteCategory =
        .init(
            name: .input,
            items: ValueType.allCases
                .excluding(
                    elementsOf: [
                        ValueType.data,
                        .attributedString,
                        .colorSpace,
                        .affineTransform,
                    ]
                )
                .map { NodeKind.valueNode($0) }
                .appending(.valueCustomNode(.affineTransform))
                .map { kind in
                    return NodePaletteItem(
                        nodeKind: kind,
                        categoryName: .input
                    )
                }
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
                .map { NodeKind.coreImageFilterNode(.colorEffect($0)) }
                .map { NodePaletteItem(nodeKind: $0, categoryName: .colorEffect) }
        )

    static let compositeOperation: NodePaletteCategory =
        .init(
            name: .compositeOperation,
            items: CIFilterNodeKind.CompositeoperationNodeKind.allCases
                .map { NodeKind.coreImageFilterNode(.compositeOperation($0)) }
                .map { NodePaletteItem(nodeKind: $0, categoryName: .compositeOperation) }
        )

    static let distortionEffect: NodePaletteCategory =
        .init(
            name: .distortionEffect,
            items: CIFilterNodeKind.DistortioneffectNodeKind.allCases
                .map { NodeKind.coreImageFilterNode(.distortionEffect($0)) }
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
                .map { NodeKind.coreImageFilterNode(.geometryAdjustment($0)) }
                .appending(elementsOf: CoreImageCustomNodeKind.GeometryAdjustment.allKinds)
                .map { NodePaletteItem(nodeKind: $0, categoryName: .geometryAdjustment) }
        )

    static let gradient: NodePaletteCategory =
        .init(
            name: .gradient,
            items: CIFilterNodeKind.GradientNodeKind.allCases
                .map { NodeKind.coreImageFilterNode(.gradient($0)) }
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
                .map { NodeKind.coreImageFilterNode(.reduction($0)) }
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
                .map { NodeKind.coreImageFilterNode(.stylize($0)) }
                .map { NodePaletteItem(nodeKind: $0, categoryName: .stylize) }
        )

    static let tileEffect: NodePaletteCategory =
        .init(
            name: .tileEffect,
            items: CIFilterNodeKind.TileeffectNodeKind.allCases
                .map { NodeKind.coreImageFilterNode(.tileEffect($0)) }
                .map { NodePaletteItem(nodeKind: $0, categoryName: .tileEffect) }
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

        result.append(Categories.math)
        result.append(Categories.input)
        result.append(Categories.blur)
        result.append(Categories.colorAdjustment)
        result.append(Categories.colorEffect)
        result.append(Categories.compositeOperation)
        result.append(Categories.distortionEffect)
        result.append(Categories.generator)
        result.append(Categories.geometryAdjustment)
        result.append(Categories.gradient)
        result.append(Categories.halftone)
        result.append(Categories.reduction)
        result.append(Categories.sharpen)
        result.append(Categories.stylize)
        result.append(Categories.tileEffect)
        result.append(Categories.transition)
        result.append(Categories.video)

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

    public func items(searchText: String = "") -> [NodePaletteItem] {
        if searchText.isEmpty {
            return self.allItems
        } else {
            return self.allItems.filter { entry in
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
    case math = "Math"
    case blur = "Blur"
    case colorAdjustment = "Color Adjustment"
    case colorEffect = "Color Effect"
    case compositeOperation = "Composite Operation"
    case distortionEffect = "Distortion"
    case generator = "Generator"
    case geometryAdjustment = "Geometry Adjustment"
    case gradient = "Gradient"
    case halftoneEffect = "Haltone"
    case reduction = "Color Reduction"
    case sharpen = "Sharpen"
    case stylize = "Stylize"
    case tileEffect = "Tile Effect"
    case transition = "Transition"
    case video = "Video"

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

    public init(nodeKind: NodeKind, categoryName: NodePaletteCategoryName) {
        self.init(
            displayName: nodeKind.displayName,
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
