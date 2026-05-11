@inline(__always)
public func updateProp<A, B: AnyObject, V: Equatable>(
    source a: A,
    _ k1: KeyPath<A, V>,
    dest b: B,
    _ k2: ReferenceWritableKeyPath<B, V>
) {
    if b[keyPath: k2] != a[keyPath: k1] {
        b[keyPath: k2] = a[keyPath: k1]
    }
}

@inline(__always)
public func updateProp<A, B: AnyObject, V: Equatable>(
    source a: A,
    _ k1: KeyPath<A, V?>,
    dest b: B,
    _ k2: ReferenceWritableKeyPath<B, V>
) {
    if let v = a[keyPath: k1], b[keyPath: k2] != v {
        b[keyPath: k2] = v
    }
}
