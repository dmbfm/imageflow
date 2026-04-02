extension ClosedRange where Bound: BinaryFloatingPoint {
    public var span: Bound {
        abs(self.upperBound - self.lowerBound)
    }

    public func progress(_ value: Bound) -> Bound {
        (value - self.lowerBound) / (self.upperBound - self.lowerBound)
    }
}
