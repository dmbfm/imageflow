import CoreGraphics

extension CGRect {
    public mutating func setX(_ x: CGFloat) {
        self.origin.x = x
    }

    public mutating func setY(_ y: CGFloat) {
        self.origin.y = y
    }

    public mutating func setWidth(_ width: CGFloat) {
        self.size.width = width
    }

    public mutating func setHeight(_ height: CGFloat) {
        self.size.height = height
    }

    public mutating func setCenterY(_ y: CGFloat) {
        self.origin.y = y - self.height / 2
    }

    init(x: CGFloat, y: CGFloat, squareSize: CGFloat) {
        self.init(x: x, y: y, width: squareSize, height: squareSize)
    }
}
