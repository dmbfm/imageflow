extension Value {
    public func cast(to type: ValueType) -> Value? {
        switch self {
        case .int(let value):
            switch type {
            case .float:
                .float(Double(value))
            case .vector2:
                .vector2(.init(x: Double(value), y: Double(value)))
            case .vector3:
                .vector3(.init(x: Double(value), y: Double(value), z: Double(value)))
            case .vector4:
                .vector4(.init(x: Double(value), y: Double(value), z: Double(value), w: Double(value)))
            case .affineTransform:
                .affineTransform(.init(m11: 1, m12: 0, m21: 0, m22: 1, tX: Double(value), tY: 0))
            case .bool:
                .bool(value != 0)
            case .color4:
                .color4(
                    .init(red: Double(value) / 256, green: Double(value) / 256, blue: Double(value) / 256, alpha: 1.0)
                )
            case .rect:
                .rect(.init(x: 0, y: 0, width: Double(value), height: Double(value)))
            default:
                nil
            }
        case .float(let value):
            switch type {
            case .int:
                .int(Int(value))
            case .vector2: .vector2(.init(x: value, y: value))
            case .vector3: .vector3(.init(x: value, y: value, z: value))
            case .vector4: .vector4(.init(x: value, y: value, z: value, w: value))
            case .affineTransform: .affineTransform(.init(m11: 1, m12: 0, m21: 0, m22: 1, tX: value, tY: 0))
            case .bool: .bool(value != 0)
            case .color4: .color4(.init(red: value, green: 0, blue: 0, alpha: 1))
            case .rect: .rect(.init(x: value, y: 0, width: 0, height: 0))
            default:
                nil
            }
        case .vector2(let value):
            switch type {
            case .float: .float(value.x)
            case .int: .int(Int(value.x))
            case .vector3: .vector3(.init(x: value.x, y: value.y, z: 0.0))
            case .vector4: .vector4(.init(x: value.x, y: value.y, z: 0.0, w: 0.0))
            default: nil
            }
        case .vector3(let value):
            switch type {
            case .float: .float(value.x)
            case .int: .int(Int(value.x))
            case .vector2: .vector2(.init(x: value.x, y: value.y))
            case .vector4: .vector4(.init(x: value.x, y: value.y, z: value.z, w: 0.0))
            case .color4: .color4(.init(red: value.x, green: value.y, blue: value.z, alpha: 1.0))
            default: nil
            }
        case .vector4(let value):
            switch type {
            case .float: .float(value.x)
            case .int: .int(Int(value.x))
            case .vector2: .vector2(.init(x: value.x, y: value.y))
            case .vector3: .vector3(.init(x: value.x, y: value.y, z: value.z))
            case .color4: .color4(.init(red: value.x, green: value.y, blue: value.z, alpha: value.w))
            case .rect: .rect(.init(x: value.x, y: value.y, width: value.z, height: value.w))
            default: nil
            }
        case .rect(let value):
            switch type {
            case .int: .int(Int(value.origin.x))
            case .float: .float(value.origin.x)
            case .vector2: .vector2(.init(x: value.origin.x, y: value.origin.y))
            case .vector3: .vector3(.init(x: value.origin.x, y: value.origin.y, z: value.width))
            case .vector4: .vector4(.init(x: value.origin.x, y: value.origin.y, z: value.width, w: value.height))
            default: nil
            }
        default:
            nil
        }
    }
}

extension ValueType {
    public var castableTypes: [ValueType] {
        switch self {
        case .int: [.float, .vector2, .vector3, .vector4, .affineTransform, .bool, .color4, .rect]
        case .float: [.int, .vector2, .vector3, .vector4, .affineTransform, .bool, .color4, .rect]
        case .vector2: [.int, .float, .vector3, .vector4]
        case .vector3: [.int, .float, .vector2, .vector4, .color4]
        case .vector4: [.int, .float, .vector2, .vector3, .color4, .rect]
        case .rect: [.int, .float, .vector2, .vector3, .vector4]
        default: []
        }
    }

    public func castable(to other: ValueType) -> Bool {
        return self.castableTypes.contains(other)
    }
}
