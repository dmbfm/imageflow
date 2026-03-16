import Foundation

public extension Double {
    func truncateTo(fractionalDigits n: Int) -> Double {
        let factor = pow(10.0, Double(n))
        return trunc(self * factor) / factor
    }

    func roundTo(fractionalDigits n: Int) -> Double {
        let factor = pow(10.0, Double(n))
        return (self * factor).rounded() / factor
    }
}

public extension Float {
    func truncateTo(fractionalDigits n: Int) -> Float {
        let factor = powf(10.0, Float(n))
        return truncf(self * factor) / factor
    }

    func roundTo(fractionalDigits n: Int) -> Float {
        let factor = powf(10.0, Float(n))
        return (self * factor).rounded() / factor
    }
}

public extension CGFloat {
    func truncateTo(fractionalDigits n: Int) -> Self {
        CGFloat(Double(self).truncateTo(fractionalDigits: n))
    }

    func roundTo(fractionalDigits n: Int) -> Self {
        CGFloat(Double(self).roundTo(fractionalDigits: n))
    }
}
