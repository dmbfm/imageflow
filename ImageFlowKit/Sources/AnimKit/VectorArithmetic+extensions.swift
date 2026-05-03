import SwiftUI

extension VectorArithmetic {
    public static func * (lhs: Self, rhs: Double) -> Self {
        lhs.scaled(by: rhs)
    }

    public static func * (lhs: Double, rhs: Self) -> Self {
        rhs.scaled(by: lhs)
    }
}
