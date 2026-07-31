@preconcurrency import CoreImage
import Foundation

public struct Vector2: Sendable, Hashable, Codable {
    public var x: Double
    public var y: Double

    public static var zero: Vector2 { Vector2(x: 0, y: 0) }

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func * (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    public static func / (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    public func dot(_ v: Self) -> Double {
        self.x * v.x + self.y * v.y
    }

    public var lenght2: Double {
        self.x * self.x + self.y * self.y
    }

    public var lenght: Double {
        sqrt(self.lenght2)
    }

    public static func * (lhs: Double, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    public var normalized: Self {
        (1.0 / self.lenght) * self
    }

    public func distance(_ v: Self) -> Double {
        (self - v).lenght
    }

    public var cgPoint: CGPoint {
        .init(x: self.x, y: self.y)
    }

    public var ciVector: CIVector {
        .init(cgPoint: self.cgPoint)
    }

    public subscript(_ index: Int) -> Double {
        get {
            switch index {
            case 0: self.x
            case 1: self.y
            default: fatalError("Out of range")
            }
        }

        set {
            switch index {
            case 0: self.x = newValue
            case 1: self.y = newValue
            default: fatalError("Out of range")
            }
        }
    }
}

public struct Vector3: Sendable, Hashable, Codable {
    public var x: Double
    public var y: Double
    public var z: Double

    public static var zero: Vector3 { Vector3(x: 0, y: 0, z: 0) }

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public static func + (lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    public static func - (lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }

    public static func * (lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
    }

    public static func / (lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
    }

    public func dot(_ v: Self) -> Double {
        self.x * v.x + self.y * v.y + self.z + v.z
    }

    public func cross(_ v: Self) -> Self {
        .init(
            x: self.y * v.z - self.z * v.y,
            y: self.z * v.x - self.x * v.z,
            z: self.x * v.y - self.y * v.x
        )
    }

    public var lenght2: Double {
        self.x * self.x + self.y * self.y + self.z * self.z
    }

    public var lenght: Double {
        sqrt(self.lenght2)
    }

    public static func * (lhs: Double, rhs: Vector3) -> Vector3 {
        Vector3(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
    }

    public var normalized: Self {
        (1.0 / self.lenght) * self
    }

    public func distance(_ v: Self) -> Double {
        (self - v).lenght
    }

    public var ciVector: CIVector {
        .init(x: self.x, y: self.y, z: self.z)
    }

    public subscript(_ index: Int) -> Double {
        get {
            switch index {
            case 0: self.x
            case 1: self.y
            case 2: self.z
            default: fatalError("Out of range")
            }
        }

        set {
            switch index {
            case 0: self.x = newValue
            case 1: self.y = newValue
            case 2: self.z = newValue
            default: fatalError("Out of range")
            }
        }
    }
}

public struct Vector4: Sendable, Hashable, Codable {
    public var x: Double
    public var y: Double
    public var z: Double
    public var w: Double

    public static var zero: Vector4 { Vector4(x: 0, y: 0, z: 0, w: 0) }

    public init(x: Double, y: Double, z: Double, w: Double) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }

    public static func + (lhs: Vector4, rhs: Vector4) -> Vector4 {
        Vector4(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z, w: lhs.w + rhs.w)
    }

    public static func - (lhs: Vector4, rhs: Vector4) -> Vector4 {
        Vector4(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z, w: lhs.w - rhs.w)
    }

    public static func * (lhs: Vector4, rhs: Vector4) -> Vector4 {
        Vector4(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z, w: lhs.w * rhs.w)
    }

    public static func / (lhs: Vector4, rhs: Vector4) -> Vector4 {
        Vector4(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z, w: lhs.w / rhs.w)
    }

    public func dot(_ v: Self) -> Double {
        self.x * v.x + self.y * v.y + self.z + v.z + self.w + v.w
    }

    public var lenght2: Double {
        self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
    }

    public var lenght: Double {
        sqrt(self.lenght2)
    }

    public static func * (lhs: Double, rhs: Vector4) -> Vector4 {
        Vector4(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z, w: lhs * rhs.w)
    }

    public var normalized: Self {
        (1.0 / self.lenght) * self
    }

    public func distance(_ v: Self) -> Double {
        (self - v).lenght
    }

    public var ciVector: CIVector {
        .init(x: self.x, y: self.y, z: self.z, w: self.w)
    }

    public subscript(_ index: Int) -> Double {
        get {
            switch index {
            case 0: self.x
            case 1: self.y
            case 2: self.z
            case 3: self.w
            default: fatalError("Out of range")
            }
        }

        set {
            switch index {
            case 0: self.x = newValue
            case 1: self.y = newValue
            case 2: self.z = newValue
            case 3: self.w = newValue
            default: fatalError("Out of range")
            }
        }
    }
}
