import Foundation
import Values

public enum NumericValueType: Sendable, Equatable, Codable, CaseIterable {
    case float
    case int
    case vector2
    case vector3
    case vector4
    case color4
    case affineTransform
    case matrix2x2
    case matrix3x3
    case matrix5x5
    case matrix7x7

    public var valueType: ValueType {
        switch self {
        case .float: .float
        case .int: .int
        case .vector2: .vector2
        case .vector3: .vector3
        case .vector4: .vector4
        case .color4: .color4
        case .affineTransform: .affineTransform
        case .matrix2x2: .matrix2x2
        case .matrix3x3: .matrix3x3
        case .matrix5x5: .matrix5x5
        case .matrix7x7: .matrix7x7
        }
    }
}

public enum NumericDivValueType: Sendable, Equatable, Codable, CaseIterable {
    case float
    case int
    case vector2
    case vector3
    case vector4
    case color4

    public var valueType: ValueType {
        switch self {
        case .float: .float
        case .int: .int
        case .vector2: .vector2
        case .vector3: .vector3
        case .vector4: .vector4
        case .color4: .color4
        }
    }
}
