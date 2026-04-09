public extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }

    func clamped(to limits: PartialRangeFrom<Self>) -> Self {
        return max(limits.lowerBound, self)
    }

}
