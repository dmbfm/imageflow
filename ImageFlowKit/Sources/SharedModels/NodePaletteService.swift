import Backend
import Values

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

        let blacklistedValueTypes: [ValueType] = [.data, .attributedString, .colorSpace, .affineTransform]

        // math
        result.append(
            .init(
                name: .math,
                items: [
                    .init(
                        displayName: "Add",
                        icon: NodeKind.addNode(.float).icon,
                        nodeKind: .addNode(.float),
                        categoryName: .math
                    )
                ]
            )
        )

        // input
        result.append(
            .init(
                name: .input,
                items: ValueType.allCases.filter({ !blacklistedValueTypes.contains($0) }).map { type in
                    let kind: NodeKind = .valueNode(type)
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .input
                    )
                }
                    + [
                        .init(
                            displayName: "Affine Transform",
                            icon: NodeKind.valueCustomNode(.affineTransform).icon,
                            nodeKind: .valueCustomNode(.affineTransform),
                            categoryName: .input
                        )
                    ]
            )
        )

        // blur
        result.append(
            .init(
                name: .blur,
                items: CIFilterNodeKind.BlurNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.blur(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .blur
                    )
                }
            )
        )

        // colorAdjustment
        result.append(
            .init(
                name: .colorAdjustment,
                items: (CIFilterNodeKind.ColoradjustmentNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.colorAdjustment(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .colorAdjustment
                    )
                }
                    + CoreImageCustomNodeKind.ColorAdjustment.allCases
                    .map { $0.kind }
                    .map {
                        .init(displayName: $0.displayName, icon: $0.icon, nodeKind: $0, categoryName: .colorAdjustment)
                    })
            )
        )

        // colorEffect
        result.append(
            .init(
                name: .colorEffect,
                items: CIFilterNodeKind.ColoreffectNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.colorEffect(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .colorEffect
                    )
                }
            )
        )

        // compositeOperation
        result.append(
            .init(
                name: .compositeOperation,
                items: CIFilterNodeKind.CompositeoperationNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.compositeOperation(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .compositeOperation
                    )
                }
            )
        )

        // distortionEffect
        result.append(
            .init(
                name: .distortionEffect,
                items: CIFilterNodeKind.DistortioneffectNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.distortionEffect(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .distortionEffect
                    )
                }
            )
        )

        // Generator
        result.append(
            .init(
                name: .generator,
                items: CIFilterNodeKind.GeneratorNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.generator(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .generator
                    )
                }
            )
        )

        // Geometry Adjustment
        result.append(
            .init(
                name: .geometryAdjustment,
                items: CIFilterNodeKind.GeometryadjustmentNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.geometryAdjustment(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .geometryAdjustment
                    )
                }
                    + CoreImageCustomNodeKind.GeometryAdjustment.allCases
                    .map { $0.kind }
                    .map {
                        .init(
                            displayName: $0.displayName,
                            icon: $0.icon,
                            nodeKind: $0,
                            categoryName: .geometryAdjustment
                        )
                    }
            )
        )

        // gradient
        result.append(
            .init(
                name: .gradient,
                items: CIFilterNodeKind.GradientNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.gradient(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .gradient
                    )
                }
            )
        )

        // halftone
        result.append(
            .init(
                name: .halftoneEffect,
                items: CIFilterNodeKind.HalftoneeffectNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.halftoneEffect(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .halftoneEffect
                    )
                }
            )
        )

        // reduction
        result.append(
            .init(
                name: .reduction,
                items: CIFilterNodeKind.ReductionNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.reduction(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .reduction
                    )
                }
            )
        )

        // sharpen
        result.append(
            .init(
                name: .sharpen,
                items: CIFilterNodeKind.SharpenNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.sharpen(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .sharpen
                    )
                }
            )
        )

        // stylize
        result.append(
            .init(
                name: .stylize,
                items: CIFilterNodeKind.StylizeNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.stylize(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .stylize
                    )
                }
            )
        )

        // tile effect
        result.append(
            .init(
                name: .tileEffect,
                items: CIFilterNodeKind.TileeffectNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.tileEffect(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .tileEffect
                    )
                }
            )
        )
        // transition
        result.append(
            .init(
                name: .transition,
                items: CIFilterNodeKind.TransitionNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.transition(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .transition
                    )
                }
            )
        )
        // Video
        result.append(
            .init(
                name: .video,
                items: CIFilterNodeKind.VideoNodeKind.allCases.map { type in
                    let kind = NodeKind.coreImageFilterNode(.video(type))
                    return NodePaletteItem(
                        displayName: kind.displayName,
                        icon: kind.icon,
                        nodeKind: kind,
                        categoryName: .video
                    )
                }
            )
        )

        return
            result
            .map { .init(name: $0.name, items: $0.items.sorted(by: { $0.displayName < $1.displayName })) }
    }()

    public init() {}

    public static let shared: NodePaletteService = .init()

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

public struct NodePaletteItem: Sendable, Hashable, Identifiable {
    public var displayName: String
    public var icon: String
    public var nodeKind: NodeKind
    public var categoryName: NodePaletteCategoryName

    public var id: Self { self }
}
