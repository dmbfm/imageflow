import Helpers
import SwiftUI

extension CGPoint: @retroactive VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        self.x *= rhs
        self.y *= rhs
    }

    public var magnitudeSquared: Double {
        self.x * self.x + self.y * self.y
    }
}

extension CGSize: @retroactive VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        self.width *= rhs
        self.height *= rhs
    }

    public var magnitudeSquared: Double {
        self.width * self.width + self.height * self.height
    }
}

extension CGRect: @retroactive AdditiveArithmetic {
    public static func - (lhs: CGRect, rhs: CGRect) -> CGRect {
        .init(
            x: lhs.minX - rhs.minX,
            y: lhs.minY - rhs.minY,
            width: lhs.width - rhs.width,
            height: lhs.height - rhs.height
        )
    }

    public static func + (lhs: CGRect, rhs: CGRect) -> CGRect {
        .init(
            x: lhs.minX + rhs.minX,
            y: lhs.minY + rhs.minY,
            width: lhs.width + rhs.width,
            height: lhs.height + rhs.height
        )
    }
}

extension CGRect: @retroactive VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        self.origin.scale(by: rhs)
        self.size.scale(by: rhs)
    }

    public var magnitudeSquared: Double {
        self.minX * self.minX + self.minY * self.minY + self.width * self.width + self.height * self.height
    }
}
