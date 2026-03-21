extension Optional {
    /// Returns a value computed by `result`, or the default `value` if the optional is `nil`.
    /// - Parameters:
    ///   - value: An initial, or default, value.
    ///   - result: The function that will calculate the result if the optional is not `nil`.
    ///
    /// - Returns:
    public func maybeReduce<V>(_ value: V, _ result: (V, Wrapped) -> V) -> V {
        if let w = self {
            result(value, w)
        } else {
            value
        }
    }
}
