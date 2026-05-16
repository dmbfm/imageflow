// The Swift Programming Language
// https://docs.swift.org/swift-book

import CoreGraphics
import Foundation

extension CGFloat {
    public func lerp(to: CGFloat, t: CGFloat) -> CGFloat {
        let t = Swift.min(1.0, Swift.max(0.0, t))
        return self * (1 - t) + to * t
    }
}

extension CGPoint {
    public func lerp(to: CGPoint, t: CGFloat) -> CGPoint {
        let t = Swift.min(1.0, Swift.max(0.0, t))
        return self * (1 - t) + to * t
    }
}

extension CGRect {
    public var center: CGPoint {
        get {
            CGPoint(x: self.midX, y: self.midY)
        }
        set {
            let x = newValue.x - self.size.width * 0.5
            let y = newValue.y - self.size.height * 0.5
            self.origin = .init(x: x, y: y)
        }
    }

    public mutating func setCenterX(_ value: CGFloat) {
        self.center = .init(x: value, y: self.midY)
    }

    public mutating func setCenterY(_ value: CGFloat) {
        self.center = .init(x: self.midX, y: value)
    }

    public func settingCenter(_ center: CGPoint) -> Self {
        var result = self
        result.center = center
        return result
    }

    public func settingCenterX(_ value: CGFloat) -> Self {
        var result = self
        result.setCenterX(value)
        return result
    }

    public func settingCenterY(_ value: CGFloat) -> Self {
        var result = self
        result.setCenterY(value)
        return result
    }
}

extension CGPoint {
    // Add + operator
    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    // Add += operator
    public static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }

    // Add - operator
    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    // Add - operator
    public static prefix func - (rhs: CGPoint) -> CGPoint {
        CGPoint(x: -rhs.x, y: -rhs.y)
    }

    // Add -= operator
    public static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs - rhs
    }

    // Add * operator
    public static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    // Add *= operator
    public static func *= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs * rhs
    }

    // Add / operator
    public static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    // Add /= operator
    public static func /= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs / rhs
    }

    // Add * operator for memberWise multiplication
    public static func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    // Add *= operator for memberWise multiplication
    public static func *= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs * rhs
    }

    // Add / operator for memberWise division
    public static func / (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }

    // Add /= operator for memberWise division
    public static func /= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs / rhs
    }

    // Add dot product
    public func dot(_ other: CGPoint) -> CGFloat {
        self.x * other.x + self.y * other.y
    }

    // Add magnitude
    public var magnitude: CGFloat {
        sqrt(self.x * self.x + self.y * self.y)
    }

    public var cgSize: CGSize {
        CGSize(width: self.x, height: self.y)
    }

    public init(cgSize: CGSize) {
        self.init(x: cgSize.width, y: cgSize.height)
    }

    public func distance(to other: CGPoint) -> CGFloat {
        (self - other).magnitude
    }

    //    func applying(_ transform: CGAffineTransform) -> CGPoint {
    //        return CGPointApplyAffineTransform(self, transform)
    //    }
    //
    public func applying(inverseOf transform: CGAffineTransform) -> CGPoint {
        CGPointApplyAffineTransform(self, CGAffineTransformInvert(transform))
    }
}

extension CGSize {
    public var cgPoint: CGPoint {
        CGPoint(x: self.width, y: self.height)
    }

    public init(cgPoint: CGPoint) {
        self.init(width: cgPoint.x, height: cgPoint.y)
    }

    //    func applying(_ transform: CGAffineTransform) -> CGSize {
    //        return CGSizeApplyAffineTransform(self, transform)
    //    }
    //
    public func applying(inverseOf transform: CGAffineTransform) -> CGSize {
        CGSizeApplyAffineTransform(self, CGAffineTransformInvert(transform))
    }

    // + operator
    public static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    // += operator
    public static func += (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs + rhs
    }

    // - operator
    public static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    // - operator
    public static prefix func - (rhs: CGSize) -> CGSize {
        CGSize(width: -rhs.width, height: -rhs.height)
    }

    // -= operator
    public static func -= (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs - rhs
    }

    // / operator with CGFloat
    public static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }

    // /= operator with CGFloat
    public static func /= (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs / rhs
    }

    // * operator with CGFloat
    public static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    // *= operator with CGFloat
    public static func *= (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs * rhs
    }
}

extension CGPoint {
    public func clamped(toRect rect: CGRect) -> CGPoint {
        .init(x: self.x.clamped(to: rect.minX...rect.maxX), y: self.y.clamped(to: rect.minY...rect.maxY))
    }
}

extension Array where Element == CGPoint {
    public var centerPoint: CGPoint? {
        guard !self.isEmpty else { return nil }
        return self.reduce(
            CGPoint.zero,
            { acc, point in
                acc + point
            }
        ) / CGFloat(self.count)
    }
}
