//
//  ValueType+icon.swift
//  Models
//
//  Created by Daniel Fortes on 27/04/25.
//

import Values

extension ValueType {
    public var icon: String {
        switch self {
        case .float, .vector2, .vector3, .vector4:
            return "number"
        case .int:
            return "number"
        case .bool:
            return "switch.2"
        case .string:
            return "textformat"
        case .image:
            return "photo"
        case .lut:
            return "squareshape.split.3x3"
        case .color3, .color4:
            return "swatchpalette"
        case .rect:
            return "square.dashed"
        case .colorSpace:
            return "paintpalette.fill"
        default:
            return "questionmark"
        }
    }
}
