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

    public var valueType: ValueType {
        switch self {
        case .float: .float
        case .int: .int
        case .vector2: .vector2
        case .vector3: .vector3
        case .vector4: .vector4
        case .color4: .color4
        case .affineTransform: .affineTransform
        }
    }
}
