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

    public var cgPoint: CGPoint {
        .init(x: self.x, y: self.y)
    }

    public var ciVector: CIVector {
        .init(cgPoint: self.cgPoint)
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

    public var ciVector: CIVector {
        .init(x: self.x, y: self.y, z: self.z)
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

    public var ciVector: CIVector {
        .init(x: self.x, y: self.y, z: self.z, w: self.w)
    }
}
