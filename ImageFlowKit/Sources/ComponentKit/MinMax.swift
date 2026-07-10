public struct MinMax: Sendable, Equatable {

    // MARK: - Public

    public enum MinOrMax {
        case min
        case max

        func other() -> Self {
            switch self {
            case .max: .min
            case .min: .max
            }
        }
    }

    public var min: Double {
        get {
            self._min
        }
        set {
            self.setterImpl(.min, to: newValue)
        }
    }

    public var max: Double {
        get {
            self._max
        }

        set {
            self.setterImpl(.max, to: newValue)
        }
    }

    public init(min: Double, max: Double) {
        self._min = Swift::min(min, max)
        self._max = Swift::max(min, max)
    }

    public mutating func move(
        _ which: MinOrMax,
        byFraction fraction: Double,
        ofClampingRange range: ClosedRange<Double>
    ) {
        self.move(
            which,
            byAmount: fraction * range.span,
        )
        self.clamp(to: range)
    }

    public func moving(
        _ which: MinOrMax,
        byFraction fraction: Double,
        ofClampingRange range: ClosedRange<Double>
    ) -> Self {
        self.moving(which, byAmount: fraction * range.span).clamped(to: range)
    }

    public mutating func move(_ which: MinOrMax, byAmount amount: Double) {
        self.setterImpl(which, to: self.get(which) + amount)
    }

    public func moving(_ which: MinOrMax, byAmount amount: Double) -> Self {
        var s = self
        s.move(which, byAmount: amount)
        return s
    }

    public mutating func clamp(to range: ClosedRange<Double>) {
        self._min = self._min.clamped(to: range)
        self._max = self._max.clamped(to: range)
    }

    public func clamped(to range: ClosedRange<Double>) -> Self {
        var s = self
        s.clamp(to: range)
        return s
    }

    // MARK: - Private / Internal

    private var _min: Double

    private var _max: Double

    private func get(_ which: MinOrMax) -> Double {
        switch which {
        case .min: self._min
        case .max: self._max
        }
    }

    private func outOfBounds(_ which: MinOrMax, value: Double) -> Bool {
        switch which {
        case .max: value > self.get(which)
        case .min: value < self.get(which)
        }
    }

    private mutating func set(_ which: MinOrMax, to value: Double) {
        switch which {
        case .min: self._min = value
        case .max: self._max = value
        }
    }

    private mutating func setterImpl(_ which: MinOrMax, to value: Double) {
        if self.outOfBounds(which.other(), value: value) {
            self.set(which.other(), to: value)
        }

        self.set(which, to: value)
    }
}
