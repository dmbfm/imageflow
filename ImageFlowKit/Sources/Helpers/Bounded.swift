public struct Bounded<Value>: Sendable, Equatable where Value: Sendable & Comparable & Equatable {
    public let range: ClosedRange<Value>
    public let value: Value

    public init?(_ range: ClosedRange<Value>, _ value: Value) {
        guard range.contains(value) else {
            return nil
        }

        self.range = range
        self.value = value
    }

    public func withValue(_ value: Value) -> Self? {
        .init(self.range, value)
    }

    public func withValueClamped(_ value: Value) -> Self {
        let finalValue =
            if value < self.range.lowerBound {
                self.range.lowerBound
            } else if value > self.range.upperBound {
                self.range.upperBound
            } else {
                value
            }

        return .init(range, finalValue)!
    }
}
