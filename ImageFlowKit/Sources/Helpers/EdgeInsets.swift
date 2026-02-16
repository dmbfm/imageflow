import Foundation

public struct EdgeInsets: Sendable, Hashable {
    public var top: CGFloat
    public var bottom: CGFloat
    public var left: CGFloat
    public var right: CGFloat

    public static let zero: EdgeInsets = .init(top: 0, bottom: 0, left: 0, right: 0)

    public init(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }
}

extension CGRect {
    public enum InsetOrientation {
        case yDown
        case yUp
    }

    public func insetted(by insets: EdgeInsets, orientation: InsetOrientation = .yDown) -> Self {
        let x = self.minX + insets.left
        let y =
            switch orientation {
            case .yDown: self.minY + insets.top
            case .yUp: self.minY + insets.bottom
            }
        let w = self.width - (insets.right + insets.left)
        let h = self.height - (insets.top + insets.bottom)

        return .init(x: x, y: y, width: w, height: h)
    }

    public mutating func inset(by insets: EdgeInsets, orientation: InsetOrientation = .yDown) {
        self = self.insetted(by: insets, orientation: orientation)
    }
}

extension EdgeInsets {
    public var platformEdgeInsets: PlatformEdgeInsets {
        .init(top: self.top, left: self.left, bottom: self.bottom, right: self.right)
    }
}
