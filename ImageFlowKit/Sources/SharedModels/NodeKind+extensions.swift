//
//  NodeKind+extensions.swift
//  Models
//
//  Created by Daniel Fortes on 11/04/25.
//

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
        default: self.displayName
        }
    }

    var displayName: String {
        switch self {
        case .valueNode(let type):
            "\(type.displayName)"
        case .math(let kind):
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
        }
    }

    var frontendNodeColor: DynamicColor {
        switch self {
        case .coreImageFilterNode(_), .coreImageCustomNode(_):
            .orange
        case .valueNode(_):
            .blue
        case .math(_):
            .blue
        case .passthroughNode(_):
            .blue
        case .splitValue(_):
            .blue
        case .combineValue(_):
            .blue
        case .transform(_):
            .purple
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
        case .coreImageFilterNode(_):
            "camera.filters"
        case .coreImageCustomNode(_):
            "camera.filters"
        case .passthroughNode(_):
            "arrow.right.circle.dotted"
        case .valueNode(let valueType):
            valueType.icon
        case .splitValue(.imageRect), .splitValue(.imageSize), .splitValue(.imageOrigin):
            "photo.badge.magnifyingglass"
        case .splitValue(_):
            "arrow.trianglehead.branch"
        case .combineValue(_):
            "arrow.trianglehead.merge"
        case .transform(.rotate):
            "rectangle.landscape.rotate"
        case .transform(.scale), .transform(.scaleUniform):
            "square.resize"
        case .transform(.translate):
            "arrow.up.and.down.and.arrow.left.and.right"
        case .transform(.srt):
            NodeKind.valueNode(.affineTransform).icon
        }
    }

    var variations: [NodeKind] {
        switch self {
        case .math(.addNode(_)): NumericValueType.allCases.map { .math(.addNode($0)) }
        case .math(.subNode(_)): NumericValueType.allCases.map { .math(.subNode($0)) }
        case .math(.mulNode(_)): NumericValueType.allCases.map { .math(.mulNode($0)) }
        case .passthroughNode(_): ValueType.allCases.map { .valueNode($0) }
        default: [self]
        }
    }

    func allowedVariations(_ inputs: [Bool], _ outputs: [Bool]) -> [NodeKind] {
        switch self {
        case .math, .passthroughNode, .valueNode:
            if inputs.contains(true) || outputs.contains(true) {
                [self]
            } else {
                self.variations
            }

        default:
            self.variations
        }
    }

    var variationDisplayName: String {
        switch self {
        case .math(.addNode(let type)): type.valueType.displayName
        case .math(.subNode(let type)): type.valueType.displayName
        case .math(.mulNode(let type)): type.valueType.displayName
        case .valueNode(let type): type.displayName
        case .passthroughNode(let type): type.displayName
        default: self.displayName
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
