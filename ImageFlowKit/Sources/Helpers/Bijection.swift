public struct Bijection<A, B> {
    private var _to: (A) -> B
    private var _from: (B) -> A

    public init(to: @escaping (A) -> B, from: @escaping (B) -> A) {
        self._to = to
        self._from = from
    }

    public func to(_ a: A) -> B {
        self._to(a)
    }

    public func from(_ b: B) -> A {
        self._from(b)
    }
}
