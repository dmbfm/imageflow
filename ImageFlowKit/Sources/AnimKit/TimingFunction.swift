import Helpers
import SwiftUI

public enum TimingFunction {
    case linear
    case easing(EasingCurve, EasingType)

}

public enum EasingType {
    case easeIn
    case easeOut
    case easeInOut
}

extension TimingFunction {
    public var function: (Double) -> Double {
        switch self {
        case .linear: { $0 }
        case .easing(let curve, .easeIn): { curve.easeIn($0) }
        case .easing(let curve, .easeOut): { curve.easeIn($0) }
        case .easing(let curve, .easeInOut): { curve.easeIn($0) }
        }
    }

    public func callAsFunction(_ t: Double) -> Double {
        self.function(t)
    }

    public func callAsFunction<V: VectorArithmetic>(a: V, b: V, t: Double) -> V {
        a * (1 - t) + b * t
    }

    public func callAsFunction<V: VectorArithmetic>(a: V, b: V, t: Double, duration: Double) -> V {
        self(a: a, b: b, t: t / duration)
    }
}
