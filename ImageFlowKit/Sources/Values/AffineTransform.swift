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

    public var cgAffineTransform: CGAffineTransform {
        .init(self.m11, self.m12, self.m21, self.m22, self.tX, self.tY)
    }

    #if os(macOS)
    public var fAffineTransform: Foundation.AffineTransform {
        .init(m11: self.m11, m12: self.m12, m21: self.m21, m22: self.m22, tX: self.tX, tY: self.tY)
    }
    #endif

    #if os(iOS)
    public var nsValue: NSValue {
        return NSValue(cgAffineTransform: self.cgAffineTransform)
    }
    #endif
}
