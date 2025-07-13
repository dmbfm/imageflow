import Values

extension ValueType {
    public var displayName: String {
        switch self {
        case .affineTransform: "Affine Transform"
        case .attributedString: "Attributed String"
        case .bool: "Boolean"
        case .color3: "Color (Opaque)"
        case .color4: "Color"
        case .colorSpace: "Color Space"
        case .data: "Data"
        case .filepath: "File Path"
        case .float: "Float"
        case .image: "Image"
        case .int: "Integer"
        case .rect: "Rectangle"
        case .string: "String"
        case .vector2: "Vector 2"
        case .vector3: "Vector 3"
        case .vector4: "Vector 4"
        }
    }
}
