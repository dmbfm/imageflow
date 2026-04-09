import Values

extension ValueType {
    public var displayName: String {
        switch self {
        case .affineTransform: "Affine Transform"
        case .attributedString: "Attributed String"
        case .bool: "Boolean"
        case .color4: "Color"
        case .colorSpace: "Color Space"
        case .data: "Data"
        case .float: "Float"
        case .image: "Image"
        case .lut: "LUT"
        case .int: "Integer"
        case .rect: "Rectangle"
        case .string: "String"
        case .vector2: "Vector 2"
        case .vector3: "Vector 3"
        case .vector4: "Vector 4"
        case .matrix3x3: "Matrix 3x3"
        case .matrix5x5: "Matrix 5x5"
        case .matrix7x7: "Matrix 7x7"
        }
    }
}
