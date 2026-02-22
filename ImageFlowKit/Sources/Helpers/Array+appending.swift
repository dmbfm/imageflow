extension Array {
    public func appending(_ element: Element) -> Self {
        self + [element]
    }
    
    public func appending(_ element: @autoclosure () -> Element, ifCondition condition: () -> Bool) -> Self {
        if condition() {
            self + [element()]
        } else {
            self
        }
    }
    
    public func appending(maybeElement: Element?) -> Self {
        if let element = maybeElement {
            self + [element]
        } else {
            self
        }
    }
    

    public func appending<S>(elementsOf other: S) -> Self where S: Sequence<Element> {
        self + other
    }
}
