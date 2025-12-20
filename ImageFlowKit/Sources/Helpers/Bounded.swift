public struct Bounded<Value>: Sendable, Equatable where Value: Sendable & Comparable & Equatable {
    public let range: ClosedRange<Value>
    public let value: Value

    public init(_ range: ClosedRange<Value>, _ value: Value) {
        self.range = range
        self.value = range.clamp(value)
    }

    public func withValue(_ value: Value) -> Self {
        .init(self.range, value)
    }

    public func withRange(_ range: ClosedRange<Value>) -> Self {
        .init(range, self.value)
    }
}

extension ClosedRange where Bound: Sendable & Comparable & Equatable {
    func clamp(_ value: Bound) -> Bound {
        if value < self.lowerBound {
            self.lowerBound
        } else if value > self.upperBound {
            self.upperBound
        } else {
            value
        }
    }
}
