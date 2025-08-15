import CoreGraphics

extension CGRect {
    public func insetted(by insets: PlatformEdgeInsets) -> CGRect {
        .init(
            x: self.minX + insets.left,
            y: self.minY + insets.top,
            width: self.width - (insets.left + insets.right),
            height: self.height - (insets.top + insets.bottom)
        )
    }
}
