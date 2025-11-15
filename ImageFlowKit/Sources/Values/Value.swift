import CoreGraphics
import Foundation
import SwiftUI

public enum Value: Sendable, Hashable, Codable {
    case float(Double)
    case int(Int)
    case bool(Bool)
    case rect(CGRect)
    case vector2(Vector2)
    case vector3(Vector3)
    case vector4(Vector4)
    case color3(Color3)
    case color4(Color4)
    case image(ImageValue)
    case string(String)
    case data(Data)
    case colorSpace(ColorSpace)
    case affineTransform(AffineTransform)
    case attributedString(AttributedString)
    case lut(LutValue)

    // Accessors for every case defined above

    public var float: Double {
        get {
            if case .float(let value) = self {
                return value
            }
            fatalError("Value is not a float: \(self.type)")
        }
        set {
            self = .float(newValue)
        }
    }

    public var int: Int {
        get {
            if case .int(let value) = self {
                return value
            }
            fatalError("Value is not an int: \(self.type)")
        }
        set {
            if case .int(_) = self {
                self = .int(newValue)
            } else {
                fatalError("Value is not an int: \(self.type)")
            }
        }
    }

    public var bool: Bool {
        get {
            if case .bool(let value) = self {
                return value
            }
            fatalError("Value is not a bool: \(self.type)")
        }
        set {
            if case .bool(_) = self {
                self = .bool(newValue)
            } else {
                fatalError("Value is not a bool: \(self.type)")
            }
        }
    }

    public var rect: CGRect {
        get {
            if case .rect(let value) = self {
                return value
            }
            fatalError("Value is not a rect: \(self.type)")
        }
        set {
            if case .rect(_) = self {
                self = .rect(newValue)
            } else {
                fatalError("Value is not a rect: \(self.type)")
            }
        }
    }

    public var vector2: Vector2 {
        get {
            if case .vector2(let value) = self {
                return value
            }
            fatalError("Value is not a vector2: \(self.type)")
        }
        set {
            if case .vector2(_) = self {
                self = .vector2(newValue)
            } else {
                fatalError("Value is not a vector2: \(self.type)")
            }
        }
    }

    public var vector3: Vector3 {
        get {
            if case .vector3(let value) = self {
                return value
            }
            fatalError("Value is not a vector3: \(self.type)")
        }
        set {
            if case .vector3(_) = self {
                self = .vector3(newValue)
            } else {
                fatalError("Value is not a vector3: \(self.type)")
            }
        }
    }

    public var vector4: Vector4 {
        get {
            if case .vector4(let value) = self {
                return value
            }
            fatalError("Value is not a vector4: \(self.type)")
        }
        set {
            if case .vector4(_) = self {
                self = .vector4(newValue)
            } else {
                fatalError("Value is not a vector4: \(self.type)")
            }
        }
    }

    public var color3: Color3 {
        get {
            if case .color3(let value) = self {
                return value
            }
            fatalError("Value is not a color3: \(self.type)")
        }
        set {
            if case .color3(_) = self {
                self = .color3(newValue)
            } else {
                fatalError("Value is not a color3: \(self.type)")
            }
        }
    }

    public var color4: Color4 {
        get {
            if case .color4(let value) = self {
                return value
            }
            fatalError("Value is not a color4: \(self.type)")
        }
        set {
            if case .color4(_) = self {
                self = .color4(newValue)
            } else {
                fatalError("Value is not a color4: \(self.type)")
            }
        }
    }

    public var image: ImageValue {
        get {
            if case .image(let value) = self {
                return value
            }
            fatalError("Value is not an image: \(self.type)")
        }
        set {
            if case .image(_) = self {
                self = .image(newValue)
            } else {
                fatalError("Value is not an image: \(self.type)")
            }
        }
    }

    public var lut: LutValue {
        get {
            if case .lut(let value) = self {
                return value
            }
            fatalError("Value is not an lut: \(self.type)")
        }
        set {
            if case .lut(_) = self {
                self = .lut(newValue)
            } else {
                fatalError("Value is not an lut: \(self.type)")
            }
        }
    }

    public var string: String {
        get {
            if case .string(let value) = self {
                return value
            }
            fatalError("Value is not a string: \(self.type)")
        }
        set {
            if case .string(_) = self {
                self = .string(newValue)
            } else {
                fatalError("Value is not a string: \(self.type)")
            }
        }
    }

    public var data: Data {
        get {
            if case .data(let value) = self {
                return value
            }
            fatalError("Value is not a data: \(self.type)")
        }
        set {
            if case .data(_) = self {
                self = .data(newValue)
            } else {
                fatalError("Value is not a data: \(self.type)")
            }
        }
    }

    public var colorSpace: ColorSpace {
        get {
            if case .colorSpace(let value) = self {
                return value
            }
            fatalError("Value is not a colorSpace: \(self.type)")
        }
        set {
            if case .colorSpace(_) = self {
                self = .colorSpace(newValue)
            } else {
                fatalError("Value is not a colorSpace: \(self.type)")
            }
        }
    }

    public var affineTransform: AffineTransform {
        get {
            if case .affineTransform(let value) = self {
                return value
            }
            fatalError("Value is not an affineTransform: \(self.type)")
        }
        set {
            if case .affineTransform(_) = self {
                self = .affineTransform(newValue)
            } else {
                fatalError("Value is not an affineTransform: \(self.type)")
            }
        }
    }

    public var attributedString: AttributedString {
        get {
            if case .attributedString(let value) = self {
                return value
            }
            fatalError("Value is not an attributedString: \(self.type)")
        }
        set {
            if case .attributedString(_) = self {
                self = .attributedString(newValue)
            } else {
                fatalError("Value is not an attributedString: \(self.type)")
            }
        }
    }

    public var maybeFloat: Float? {
        get {
            if case .float(let value) = self {
                return Float(value)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .float(Double(newValue))
            } else {
                fatalError("Value is not a float: \(self.type)")
            }
        }
    }

    public var maybeInt: Int? {
        get {
            if case .int(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .int(newValue)
            } else {
                fatalError("Value is not an int: \(self.type)")
            }
        }
    }

    public var maybeBool: Bool? {
        get {
            if case .bool(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .bool(newValue)
            } else {
                fatalError("Value is not a bool: \(self.type)")
            }
        }
    }

    public var maybeRect: CGRect? {
        get {
            if case .rect(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .rect(newValue)
            } else {
                fatalError("Value is not a rect: \(self.type)")
            }
        }
    }

    public var maybeVector2: Vector2? {
        get {
            if case .vector2(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .vector2(newValue)
            } else {
                fatalError("Value is not a vector2: \(self.type)")
            }
        }
    }

    public var maybeVector3: Vector3? {
        get {
            if case .vector3(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .vector3(newValue)
            } else {
                fatalError("Value is not a vector3: \(self.type)")
            }
        }
    }

    public var maybeVector4: Vector4? {
        get {
            if case .vector4(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .vector4(newValue)
            } else {
                fatalError("Value is not a vector4: \(self.type)")
            }
        }
    }

    public var maybeColor3: Color3? {
        get {
            if case .color3(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .color3(newValue)
            } else {
                fatalError("Value is not a color3: \(self.type)")
            }
        }
    }

    public var maybeColor4: Color4? {
        get {
            if case .color4(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .color4(newValue)
            } else {
                fatalError("Value is not a color4: \(self.type)")
            }
        }
    }

    public var maybeImage: ImageValue? {
        get {
            if case .image(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .image(newValue)
            } else {
                fatalError("Value is not an image: \(self.type)")
            }
        }
    }

    public var maybeString: String? {
        get {
            if case .string(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .string(newValue)
            } else {
                fatalError("Value is not a string: \(self.type)")
            }
        }
    }

    public var maybeData: Data? {
        get {
            if case .data(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .data(newValue)
            } else {
                fatalError("Value is not a data: \(self.type)")
            }
        }
    }

    public var maybeColorSpace: ColorSpace? {
        get {
            if case .colorSpace(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .colorSpace(newValue)
            } else {
                fatalError("Value is not a colorSpace: \(self.type)")
            }
        }
    }

    public var maybeAffineTransform: AffineTransform? {
        get {
            if case .affineTransform(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .affineTransform(newValue)
            } else {
                fatalError("Value is not an affineTransform: \(self.type)")
            }
        }
    }

    public var maybeAttributedString: AttributedString? {
        get {
            if case .attributedString(let value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                self = .attributedString(newValue)
            } else {
                fatalError("Value is not an attributedString: \(self.type)")
            }
        }
    }
}

public typealias ImageValue = Optional<AssetIdentifier>

public typealias LutValue = Optional<AssetIdentifier>

public enum AssetIdentifier: Sendable, Hashable, Codable {
    case nodeOutput(UUID, Int)
    case asset(UUID)
}

extension Value {
    public func `is`(sameTypeAs other: Value) -> Bool {
        self.type == other.type
    }

    public func `is`(_ type: ValueType) -> Bool {
        self.type == type
    }

    public func convert(to type: ValueType) -> Self? {
        switch (self, type) {

        // Float to other types
        case (.float(let value), .int):
            return .int(Int(value))
        case (.float(let value), .vector2):
            return .vector2(Vector2(x: value, y: 0))
        case (.float(let value), .vector3):
            return .vector3(Vector3(x: value, y: 0, z: 0))
        case (.float(let value), .vector4):
            return .vector4(Vector4(x: value, y: 0, z: 0, w: 0))
        case (.float(let value), .color3):
            return .color3(Color3(red: value, green: 0, blue: 0))
        case (.float(let value), .color4):
            return .color4(Color4(red: value, green: 0, blue: 0, alpha: 0))

        // Int to other types
        case (.int(let value), .vector2):
            return .vector2(Vector2(x: Double(value), y: 0))
        case (.int(let value), .vector3):
            return .vector3(Vector3(x: Double(value), y: 0, z: 0))
        case (.int(let value), .vector4):
            return .vector4(Vector4(x: Double(value), y: 0, z: 0, w: 0))
        case (.int(let value), .float):
            return .float(Double(value))
        case (.int(let value), .color3):
            return .color3(Color3(red: Double(value), green: 0, blue: 0))
        case (.int(let value), .color4):
            return .color4(Color4(red: Double(value), green: 0, blue: 0, alpha: 1))

        // Vector2 to other types
        case (.vector2(let value), .float):
            return .float(value.x)
        case (.vector2(let value), .int):
            return .int(Int(value.x))
        case (.vector2(let value), .vector3):
            return .vector3(Vector3(x: value.x, y: value.y, z: 0))
        case (.vector2(let value), .vector4):
            return .vector4(Vector4(x: value.x, y: value.y, z: 0, w: 0))
        case (.vector2(let value), .color3):
            return .color3(Color3(red: value.x, green: value.y, blue: 0))
        case (.vector2(let value), .color4):
            return .color4(Color4(red: value.x, green: value.y, blue: 0, alpha: 1))

        case (.vector3, .vector4):
            return nil
        case (.vector4, .vector3):
            return nil
        case (.color3, .color4):
            return nil
        case (.color4, .color3):
            return nil
        default:
            return nil
        }
    }

    public static func defaultValue(forType type: ValueType) -> Self {
        switch type {
        case .float:
            return .float(0)
        case .int:
            return .int(0)
        case .vector2:
            return .vector2(Vector2(x: 0, y: 0))
        case .vector3:
            return .vector3(Vector3(x: 0, y: 0, z: 0))
        case .vector4:
            return .vector4(Vector4(x: 0, y: 0, z: 0, w: 0))
        case .color3:
            return .color3(Color3(red: 0, green: 0, blue: 0))
        case .color4:
            return .color4(Color4(red: 0, green: 0, blue: 0, alpha: 0))
        case .image:
            return .image(nil)
        case .lut:
            return .lut(nil)
        case .string:
            return .string("")
        case .bool:
            return .bool(false)
        case .rect:
            return .rect(.zero)
        case .data:
            return .data(Data())
        case .colorSpace:
            return .colorSpace(.sRGB)
        case .affineTransform:
            return .affineTransform(.identity)
        case .attributedString:
            return .attributedString(AttributedString())
        }
    }

    public var type: ValueType {
        switch self {
        case .float:
            return .float
        case .int:
            return .int
        case .vector2:
            return .vector2
        case .vector3:
            return .vector3
        case .vector4:
            return .vector4
        case .color3:
            return .color3
        case .color4:
            return .color4
        case .image:
            return .image
        case .lut:
            return .lut
        case .string:
            return .string
        case .bool:
            return .bool
        case .rect:
            return .rect
        case .data:
            return .data
        case .colorSpace:
            return .colorSpace
        case .affineTransform:
            return .affineTransform
        case .attributedString:
            return .attributedString
        }
    }
}

extension Value: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .float(value):
            return "Float(\(value))"
        case let .int(value):
            return "Int(\(value))"
        case let .vector2(value):
            return "Vector2(\(value.x), \(value.y))"
        case let .vector3(value):
            return "Vector3(\(value.x), \(value.y), \(value.z))"
        case let .vector4(value):
            return "Vector4(\(value.x), \(value.y), \(value.z), \(value.w))"
        case let .color3(value):
            return "Color3(\(value.red), \(value.green), \(value.blue))"
        case let .color4(value):
            return "Color4(\(value.red), \(value.green), \(value.blue), \(value.alpha))"
        case let .image(value):
            return "Image(\(value == nil ? "nil" : "\(value!)"))"
        case let .lut(value):
            return "LUT(\(value == nil ? "nil" : "\(value!)"))"
        case let .string(value):
            return "String(\(value))"
        case let .bool(value):
            return "Bool(\(value))"
        case let .rect(value):
            return "Rect(\(value))"
        case let .data(value):
            return "Data(\(value))"
        case let .colorSpace(value):
            return "ColorSpace(\(value))"
        case let .affineTransform(value):
            return "AffineTransform(\(value))"
        case let .attributedString(value):
            return "AttributedString(\(value))"
        }
    }
}

extension Binding<Vector2?> {
    public var x: Binding<Double?> {
        .init(
            get: { self.wrappedValue?.x },
            set: {
                if let newValue = $0 {
                    self.wrappedValue?.x = newValue
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }

    public var y: Binding<Double?> {
        .init(
            get: { self.wrappedValue?.y },
            set: {
                if let newValue = $0 {
                    self.wrappedValue?.y = newValue
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }
}

// the same for Vector3 and Vector4
extension Binding<Vector3?> {
    public var x: Binding<Double?> {
        .init(
            get: { self.wrappedValue?.x },
            set: {
                if let newValue = $0 {
                    self.wrappedValue?.x = newValue
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }

    public var y: Binding<Double?> {
        .init(
            get: { self.wrappedValue?.y },
            set: {
                if let newValue = $0 {
                    self.wrappedValue?.y = newValue
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }

    public var z: Binding<Double?> {
        .init(
            get: { self.wrappedValue?.z },
            set: {
                if let newValue = $0 {
                    self.wrappedValue?.z = newValue
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }
}

extension Binding<Vector4?> {
    public var x: Binding<Double?> {
        .init(
            get: { self.wrappedValue?.x },
            set: {
                if let newValue = $0 {
                    self.wrappedValue?.x = newValue
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }

    public var y: Binding<Double?> {
        .init(
            get: { self.wrappedValue?.y },
            set: {
                if let newValue = $0 {
                    self.wrappedValue?.y = newValue
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }

    public var z: Binding<Double?> {
        .init(
            get: { self.wrappedValue?.z },
            set: {
                if let newValue = $0 {
                    self.wrappedValue?.z = newValue
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }

    public var w: Binding<Double?> {
        .init(
            get: { self.wrappedValue?.w },
            set: {
                if let newValue = $0 {
                    self.wrappedValue?.w = newValue
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }
}

extension Value {
    public static func + (lhs: Value, rhs: Value) -> Value {
        switch (lhs, rhs) {
        case (.float(let lhsValue), .float(let rhsValue)):
            return .float(lhsValue + rhsValue)
        case (.int(let lhsValue), .int(let rhsValue)):
            return .int(lhsValue + rhsValue)
        case (.vector2(let lhsValue), .vector2(let rhsValue)):
            return .vector2(lhsValue + rhsValue)
        case (.vector3(let lhsValue), .vector3(let rhsValue)):
            return .vector3(lhsValue + rhsValue)
        case (.vector4(let lhsValue), .vector4(let rhsValue)):
            return .vector4(lhsValue + rhsValue)
        case (.color3(let lhsValue), .color3(let rhsValue)):
            return .color3(lhsValue + rhsValue)
        case (.color4(let lhsValue), .color4(let rhsValue)):
            return .color4(lhsValue + rhsValue)
        case (.string(let lhsValue), .string(let rhsValue)):
            return .string(lhsValue + rhsValue)
        default:
            fatalError("Invalid types: \(lhs) + \(rhs)")
        }
    }
}
