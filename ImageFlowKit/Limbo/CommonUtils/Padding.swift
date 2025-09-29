import CoreGraphics

public struct Padding: Hashable, Sendable {
    public var leading: CGFloat = 0
    public var trailing: CGFloat = 0
    public var top: CGFloat = 0
    public var bottom: CGFloat = 0

    public init(_ value: CGFloat) {
        self.leading = value
        self.trailing = value
        self.top = value
        self.bottom = value
    }

    public init(leading: CGFloat = 0, trailing: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) {
        self.leading = leading
        self.trailing = trailing
        self.top = top
        self.bottom = bottom
    }

    public func expand(_ size: CGSize) -> CGSize {
        CGSize(
            width: size.width + self.leading + self.trailing,
            height: size.height + self.top + self.bottom
        )
    }

    public func apply(_ rect: CGRect) -> CGRect {
        CGRect(
            x: rect.minX + self.leading,
            y: rect.minY + self.top,
            width: rect.width - self.leading - self.trailing,
            height: rect.height - self.top - self.bottom
        )
    }
}
