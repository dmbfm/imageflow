public enum ValueType: String, Sendable, CaseIterable, Codable {
    case float
    case int
    case bool
    case rect
    case vector2
    case vector3
    case vector4
    case color4
    case image
    case lut
    case string
    case data
    case colorSpace
    case affineTransform
    case attributedString
    case matrix2x2
    case matrix3x3
    case matrix5x5
    case matrix7x7
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
        case .color4: return "Color4"
        case .image: return "Image"
        case .lut: return "LUT"
        case .string: return "String"
        case .data: return "Data"
        case .colorSpace: return "ColorSpace"
        case .affineTransform: return "AffineTransform"
        case .attributedString: return "AttributedString"
        case .matrix2x2: return "Matrix2x2"
        case .matrix3x3: return "Matrix3x3"
        case .matrix5x5: return "Matrix5x5"
        case .matrix7x7: return "Matrix7x7"
        }
    }
}

extension ValueType {
    public var defaultValue: Value {
        .defaultValue(forType: self)
    }
}

extension ValueType {
    public func castableTypes() -> [ValueType] {
        switch self {
        case .int: [.float, .vector2, .vector3, .vector4, .affineTransform, .bool, .color4, .rect]
        case .float: [.int]
        default: []
        }
    }

    public func castable(to other: ValueType) -> Bool {
        return self.castableTypes().contains(other)
    }
}
