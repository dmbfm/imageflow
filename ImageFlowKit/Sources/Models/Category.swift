import Backend
import Values

// public enum Category: CaseIterable, Identifiable, Sendable, Hashable {
//     public var id: Self { self }
//     case math
//     case input
//     case colorAdjustment
//     case otherFilters
//     case misc

//     public var displayName: String {
//         switch self {
//         case .math: "Math"
//         case .input: "Input"
//         case .colorAdjustment: "Color Adjustment"
//         case .otherFilters: "Other Filters"
//         case .misc: "Misc"
//         }
//     }

//     public var items: [NodePaletteItem] {
//         switch self {
//         case .math:
//             [.addNode]
//         case .input:
//             ValueType.allCases.map { .valueNode($0) }
//         case .colorAdjustment:
//             []
//         //            [
//         //                CIFilterNodeKind.colorAbsoluteDifference, .colorClamp, .colorControls, .colorCrossPolynomial,
//         //                .colorCube, .colorCubeWithColorSpace, .colorCubesMixedWithMask, .colorCurves, .colorInvert,
//         //                .colorMap, .colorMatrix, .colorMonochrome, .colorPolynomial, .colorPosterize, .colorThreshold,
//         //            ].map { .coreImageFilterNode($0) }
//         default:
//             []
//         }
//     }
// }

// public enum NodePaletteItem {
//     case addNode
//     case passthroughNode
//     case valueNode(ValueType)
//     //    case coreImageFilterNode(CIFilterNodeKind)

//     public var defaultNode: NodeKind {
//         switch self {
//         case .valueNode(let type):
//             return .valueNode(type)
//         case .addNode:
//             return .addNode(.float)
//         case .passthroughNode:
//             return .passthroughNode(.float)
//         //        case .coreImageFilterNode(let filter):
//         //            return .coreImageFilterNode(filter)
//         }
//     }

//     public var displayName: String {
//         self.defaultNode.displayName
//     }

//     public var icon: String {
//         self.defaultNode.icon
//     }
// }
