import CoreGraphics

extension CGSize {
    public mutating func setWidth(_ width: CGFloat) {
        self.width = width
    }

    public mutating func setHeight(_ height: CGFloat) {
        self.height = height
    }

    public func min(_ other: CGSize) -> CGSize {
        CGSize(
            width: Swift.min(self.width, other.width),
            height: Swift.min(self.height, other.height)
        )
    }

    public func max(_ other: CGSize) -> CGSize {
        CGSize(
            width: Swift.max(self.width, other.width),
            height: Swift.max(self.height, other.height)
        )
    }

    public func minMax(_ other: CGSize, width: MinMax, height: MinMax) -> CGSize {
        CGSize(width: width(self.width, other.width), height: height(self.height, other.height))
    }

    public func clampWidth(to range: ClosedRange<CGFloat>) -> CGSize {
        .init(width: self.width.clamped(to: range), height: self.height)
    }

    public enum MinMax {
        case min
        case max
        case ours
        case theirs
        case sum

        func callAsFunction(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
            switch self {
            case .min:
                Swift.min(a, b)
            case .max:
                Swift.max(a, b)
            case .ours:
                a
            case .theirs:
                b
            case .sum:
                a + b
            }
        }
    }
}
