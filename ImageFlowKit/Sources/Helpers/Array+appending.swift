extension Array {
    public func appending(_ element: Element) -> Self {
        self + [element]
    }

    public func appending<S>(elementsOf other: S) -> Self where S: Sequence<Element> {
        self + other
    }
}
