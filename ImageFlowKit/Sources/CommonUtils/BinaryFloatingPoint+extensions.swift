import Foundation

public extension BinaryFloatingPoint {
    /// Wraps any value into the [0, 2π) interval.
    var normalizedRadians: Self {
        let twoPi = 2 * Self.pi
        // remainder in (–2π,2π)
        let r = self.truncatingRemainder(dividingBy: twoPi)
        // if negative, shift up into [0,2π)
        return r >= 0 ? r : r + twoPi
    }

    var degrees: Self {
        return self * 180 / .pi
    }

    var radians: Self {
        return self * .pi / 180
    }

    // func truncateTo(_ x: Self, n: Int) -> Double {
    //     let factor = pow(x, n)  //pow(10.0, Double(n))
    //     return floor(x * factor) / factor
    // }

    // func roundTo(_ x: Double, n: Int) -> Double {
    //     let factor = pow(10.0, Double(n))
    //     return (x * factor).rounded() / factor
    // }
}
