public enum ValueType: String, Sendable, CaseIterable, Codable {
    case float
    case int
    case bool
    case rect
    case vector2
    case vector3
    case vector4
    case color3
    case color4
    case image
    case string
    case data
    case colorSpace
    case affineTransform
    case attributedString
}

extension ValueType: Identifiable {
    public var id: Self { self }
}

extension ValueType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .float: return "Float"
        case .int: return "Int"
        case .bool: return "Bool"
        case .rect: return "Rect"
        case .vector2: return "Vector2"
        case .vector3: return "Vector3"
        case .vector4: return "Vector4"
        case .color3: return "Color3"
        case .color4: return "Color4"
        case .image: return "Image"
        case .string: return "String"
        case .data: return "Data"
        case .colorSpace: return "ColorSpace"
        case .affineTransform: return "AffineTransform"
        case .attributedString: return "AttributedString"
        }
    }
}

extension ValueType {
    public var defaultValue: Value {
        .defaultValue(forType: self)
    }
}
