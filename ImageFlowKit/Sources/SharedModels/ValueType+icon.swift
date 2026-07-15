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
        case .float:
            return "number"
        case .floatArray:
            return "number"
        case .vector2, .vector3, .vector4:
            return "arrow.up.forward"
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
        case .color4:
            return "swatchpalette"
        case .rect:
            return "square.dashed"
        case .colorSpace:
            return "paintpalette.fill"
        case .data:
            return "externaldrive.fill"
        case .affineTransform:
            return "squareshape.split.2x2"
        case .attributedString:
            return "textformat"
        case .matrix2x2:
            return "square.grid.3x3.fill"
        case .matrix3x3:
            return "square.grid.3x3.fill"
        case .matrix5x5:
            return "square.grid.3x3.fill"
        case .matrix7x7:
            return "square.grid.3x3.fill"
        case .gradientData:
            return "lightspectrum.horizontal"
        }
    }
}
