import CoreGraphics
import Foundation

public struct AffineTransform: Sendable, Codable, Hashable {
    public var m11: CGFloat
    public var m12: CGFloat
    public var m21: CGFloat
    public var m22: CGFloat
    public var tX: CGFloat
    public var tY: CGFloat

    public static var identity: Self {
        .init(m11: 1, m12: 0, m21: 0, m22: 1, tX: 0, tY: 0)
    }

    public init(m11: CGFloat, m12: CGFloat, m21: CGFloat, m22: CGFloat, tX: CGFloat, tY: CGFloat) {
        self.m11 = m11
        self.m12 = m12
        self.m21 = m21
        self.m22 = m22
        self.tX = tX
        self.tY = tY
    }

    public init(cgAffineTransform t: CGAffineTransform) {
        self.m11 = t.a
        self.m12 = t.c
        self.m21 = t.b
        self.m22 = t.d
        self.tX = t.tx
        self.tY = t.ty
    }

    public var cgAffineTransform: CGAffineTransform {
        .init(self.m11, self.m21, self.m12, self.m22, self.tX, self.tY)
    }

    public subscript(row: Int, col: Int) -> CGFloat {
        get {
            switch (row, col) {
            case (0, 0): self.m11
            case (0, 1): self.m12
            case (0, 2): self.tX
            case (1, 0): self.m21
            case (1, 1): self.m22
            case (1, 2): self.tY
            case (2, 0): 0.0
            case (2, 1): 0.0
            case (2, 2): 1.0
            default:
                fatalError("Index out of range: (\(row), \(col))")
            }
        }

        set {
            switch (row, col) {
            case (0, 0): self.m11 = newValue
            case (0, 1): self.m12 = newValue
            case (0, 2): self.tX = newValue
            case (1, 0): self.m21 = newValue
            case (1, 1): self.m22 = newValue
            case (1, 2): self.tY = newValue
            case (2, 0): break
            case (2, 1): break
            case (2, 2): break
            default:
                fatalError("Index out of range: (\(row), \(col))")
            }
        }

    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(
            m11: lhs.m11 + rhs.m11,
            m12: lhs.m12 + rhs.m12,
            m21: lhs.m21 + rhs.m21,
            m22: lhs.m22 + rhs.m22,
            tX: lhs.tX + rhs.tX,
            tY: lhs.tY + rhs.tY
        )
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(
            m11: lhs.m11 - rhs.m11,
            m12: lhs.m12 - rhs.m12,
            m21: lhs.m21 - rhs.m21,
            m22: lhs.m22 - rhs.m22,
            tX: lhs.tX - rhs.tX,
            tY: lhs.tY - rhs.tY
        )
    }

    public static func * (lhs: Self, rhs: Self) -> Self {
        .init(
            m11: lhs.m11 * rhs.m11 + lhs.m12 * rhs.m21,
            m12: lhs.m11 * rhs.m12 + lhs.m12 * rhs.m22,
            m21: lhs.m21 * rhs.m11 + lhs.m22 * rhs.m21,
            m22: lhs.m21 * rhs.m12 + lhs.m22 * rhs.m22,
            tX: lhs.m11 * rhs.tX + lhs.m12 * rhs.tY + lhs.tX,
            tY: lhs.m21 * rhs.tX + lhs.m22 * rhs.tY + lhs.tY
        )
    }

    #if os(macOS)
    public var fAffineTransform: Foundation.AffineTransform {
        .init(m11: self.m11, m12: self.m21, m21: self.m12, m22: self.m22, tX: self.tX, tY: self.tY)
    }
    #endif

    #if os(iOS)
    public var nsValue: NSValue {
        return NSValue(cgAffineTransform: self.cgAffineTransform)
    }
    #endif
}
