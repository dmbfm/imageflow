//
//  NodeKind+extensions.swift
//  Models
//
//  Created by Daniel Fortes on 11/04/25.
//

import Backend
import ColorUtils
import CommonUtils
import SwiftUI
import Values

#if canImport(AppKit)
import AppKit
#endif

public extension NodeKind {
    var displayName: String {
        switch self {
        case .coreImageFilterNode(_):
            self.schema.name
        // filter.hashValue
        // filter.rawValue.humanizedNameDroppingCIPrefix()
        case .valueNode(let type):
            "\(type.displayName)"
        case .addNode(_): "Add"
        case .passthroughNode(_): "Passthrough"
        case .angleNode: "Angle"
        }
    }

    var frontendNodeColor: DynamicColor {
        switch self {
        case .coreImageFilterNode(_):
            .orange
        case .valueNode(_):
            .blue
        case .addNode(_):
            .blue
        case .passthroughNode(_):
            .blue
        case .angleNode:
            .blue
        }
    }

    var icon: String {
        switch self {
        case .addNode(_):
            "plus.circle.fill"
        case .coreImageFilterNode(_):
            "camera.filters"
        case .passthroughNode(_):
            "arrow.right.circle.dotted"
        case .valueNode(_):
            "number.circle.fill"
        case .angleNode:
            "angle"
        }
    }

    var variations: [NodeKind] {
        switch self {
        case .addNode(_): NumericValueType.allCases.map { .addNode($0) }
        case .valueNode(_): ValueType.allCases.map { .valueNode($0) }
        case .passthroughNode(_): ValueType.allCases.map { .valueNode($0) }
        default: [self]
        }
    }

    func allowedVariations(_ inputs: [Bool], _ outputs: [Bool]) -> [NodeKind] {
        switch self {
        case .addNode, .passthroughNode, .valueNode:
            if (inputs.any() || outputs.any()) { [self] } else { self.variations }
        default: self.variations
        }
    }

    var variationDisplayName: String {
        switch self {
        case .addNode(let type): type.valueType.displayName
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
