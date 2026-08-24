import Backend
import Helpers
import SwiftUI
import Values

#if canImport(AppKit)
import AppKit
#endif

public extension NodeKind {

    var defaultNodeName: String {
        switch self {
        case .math(.addNode(_)): "Add"
        case .math(.mulNode(_)): "Multiply"
        case .math(.subNode(_)): "Subtract"
        case .math(.divNode(_)): "Divide"
        case .booleanOperation(.ifNode(_)): "If"
        case .booleanOperation(.equalNode(_)): "Equal"
        case .booleanOperation(.greater(_)): "Greater Than"
        case .booleanOperation(.greaterOrEqual(_)): "Greater Than or Equal"
        case .booleanOperation(.smaller(_)): "Less Than"
        case .booleanOperation(.smallerOrEqual(_)): "Less Than or Equal"
        case .vectorOperation(.dotProduct(_)): "Dot Product"
        case .vectorOperation(.pointDistance(_)): "Point Distance"
        case .vectorOperation(.vectorLength(_)): "Vector Length"
        case .vectorOperation(.vectorNormalize(_)): "Normalize Vector"
        default: self.displayName
        }
    }

    var displayName: String {
        switch self {
        case .valueNode(let type):
            "\(type.displayName)"
        case .math(let kind):
            kind.impl.schema.displayName
        case .vectorOperation(let kind):
            kind.impl.schema.displayName
        case .passthroughNode(_): "Passthrough"
        case .coreImageFilterNode(let kind):
            kind.impl.schema.displayName
        case .coreImageCustomNode(let kind):
            kind.impl.schema.displayName
        case .splitValue(let kind):
            kind.impl.schema.displayName
        case .combineValue(let kind):
            kind.impl.schema.displayName
        case .transform(let kind):
            kind.impl.schema.displayName
        case .imageTransform(let kind):
            kind.impl.schema.displayName
        case .tileEffect(let kind):
            kind.impl.schema.displayName
        case .compositeOperation(let kind):
            kind.impl.schema.displayName
        case .booleanOperation(let kind):
            kind.impl.schema.displayName
        case .mathFunction(let kind):
            kind.impl.schema.displayName
        case .experimental(let kind):
            kind.impl.schema.displayName
        case .stylize(let kind):
            kind.impl.schema.displayName

        }
    }

    var frontendNodeColor: DynamicColor {
        switch self {
        case .coreImageFilterNode(_), .coreImageCustomNode(_), .imageTransform(_), .tileEffect(_),
            .compositeOperation(_), .stylize(_):
            .orange
        case .valueNode(_):
            .blue
        case .math(_), .mathFunction(_), .vectorOperation(_):
            .blue
        case .passthroughNode(_):
            .blue
        case .splitValue(_):
            .blue
        case .combineValue(_):
            .blue
        case .transform(_):
            .purple
        case .booleanOperation(_):
            .blue
        case .experimental(_):
            .red
        }
    }

    var icon: String {
        switch self {
        case .math(.addNode(_)):
            "plus.circle.fill"
        case .math(.subNode(_)):
            "minus.circle.fill"
        case .math(.mulNode(_)):
            "multiply.circle.fill"
        case .math(.divNode(_)):
            "divide.circle.fill"
        case .mathFunction(_):
            "f.cursive"
        case .vectorOperation(_):
            "arrow.up.forward"
        case .tileEffect(_), .coreImageFilterNode(.tileEffect(_)):
            "squareshape.split.3x3"
        case .coreImageFilterNode(_), .imageTransform(.applyAffineTransform), .compositeOperation(_), .stylize(_):
            "camera.filters"
        case .coreImageCustomNode(_):
            "camera.filters"
        case .passthroughNode(_):
            "arrow.right.circle.dotted"
        case .valueNode(let valueType):
            valueType.icon
        case .splitValue(.imageRect), .splitValue(.imageSize), .splitValue(.imageOrigin):
            "photo"
        case .splitValue(_):
            "arrow.trianglehead.branch"
        case .combineValue(_):
            "arrow.trianglehead.merge"
        case .transform(.rotate), .imageTransform(.rotate):
            "rectangle.landscape.rotate"
        case .transform(.scale), .transform(.scaleUniform), .imageTransform(.scale), .imageTransform(.scaleUniform):
            "square.resize"
        case .transform(.translate), .imageTransform(.translate):
            "arrow.up.and.down.and.arrow.left.and.right"
        case .transform(.srt):
            NodeKind.valueNode(.affineTransform).icon
        case .booleanOperation(.equalNode(_)):
            "equal.circle.fill"
        case .booleanOperation(.greater(_)):
            "greaterthan.circle.fill"
        case .booleanOperation(.greaterOrEqual(_)):
            "greaterthanorequalto.circle.fill"
        case .booleanOperation(.smaller(_)):
            "lessthan.circle.fill"
        case .booleanOperation(.smallerOrEqual(_)):
            "lessthanorequalto.circle.fill"
        case .booleanOperation(_):
            "switch.2"
        case .experimental(_):
            "testtube.2"
        }
    }

    var variations: [NodeKind] {
        switch self {
        case .math(.addNode(_)): NumericValueType.allCases.map { .math(.addNode($0)) }
        case .math(.subNode(_)): NumericValueType.allCases.map { .math(.subNode($0)) }
        case .math(.mulNode(_)): NumericValueType.allCases.map { .math(.mulNode($0)) }
        case .math(.divNode(_)): NumericDivValueType.allCases.map { .math(.divNode($0)) }
        case .vectorOperation(.dotProduct(_)): VectorValueType.allCases.map { .vectorOperation(.dotProduct($0)) }
        case .vectorOperation(.pointDistance(_)): VectorValueType.allCases.map { .vectorOperation(.pointDistance($0)) }
        case .vectorOperation(.vectorLength(_)): VectorValueType.allCases.map { .vectorOperation(.vectorLength($0)) }
        case .vectorOperation(.vectorNormalize(_)):
            VectorValueType.allCases.map { .vectorOperation(.vectorNormalize($0)) }
        case .passthroughNode(_): ValueType.allCases.map { .valueNode($0) }
        case .booleanOperation(.ifNode(_)): ValueType.allCases.map { .booleanOperation(.ifNode($0)) }
        case .booleanOperation(.equalNode(_)): ValueType.allCases.map { .booleanOperation(.equalNode($0)) }
        case .booleanOperation(.greater(_)): NumericComparableValueType.allCases.map { .booleanOperation(.greater($0)) }
        case .booleanOperation(.greaterOrEqual(_)):
            NumericComparableValueType.allCases.map { .booleanOperation(.greaterOrEqual($0)) }
        case .booleanOperation(.smaller(_)): NumericComparableValueType.allCases.map { .booleanOperation(.smaller($0)) }
        case .booleanOperation(.smallerOrEqual(_)):
            NumericComparableValueType.allCases.map { .booleanOperation(.smallerOrEqual($0)) }
        default: [self]
        }
    }

    func allowedVariations(_ inputs: [Bool], _ outputs: [Bool]) -> [NodeKind] {
        switch self {
        case .math, .passthroughNode, .valueNode, .booleanOperation, .vectorOperation:
            if inputs.contains(true) || outputs.contains(true) {
                [self]
            } else {
                self.variations
            }

        default:
            self.variations
        }
    }
}

extension String {
    /// Drops a leading "CI" if present, then inserts spaces between
    /// CamelCase words *but* keeps all-caps acronyms (e.g. "RGB", "SRGB", "CMYK") intact.
    func humanizedNameDroppingCIPrefix() -> String {
        // 1) Drop CI prefix
        let raw: String
        if hasPrefix("CI") {
            raw = String(dropFirst(2))
        } else {
            raw = self
        }

        // 2) Regex to split:
        //    - between a lower/number and an upper,
        //    - or between an all-caps run and a normal word
        let pattern = #"(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])"#
        let humanized = raw.replacingOccurrences(
            of: pattern,
            with: " ",
            options: .regularExpression
        )

        return humanized
    }
}
