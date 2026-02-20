extension Array {
    public func excluding<S: Sequence>(elementsOf seq: S) -> Self where S.Element == Element, Element: Equatable {
        self.filter({ !seq.contains($0) })
    }
}
