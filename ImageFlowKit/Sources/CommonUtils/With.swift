/// A protocol that contains a single function, `with`, used to create a new
/// object by mutating a keypath of the original object. Should be used only with
/// value-types such as structs and enums.
///
/// The default implementation covers the intended effect, so to use this
/// protocol you should just add it to the protocol list for your type, without
/// giving a custom implementation.
public protocol With {
    /// Returns a new object wich is equal to the current object with the given keypath set to the given value.
    /// - Parameters:
    ///   - kp: The keypath to be mutated.
    ///   - value: The value to be assigned to the keypath.
    ///
    /// - Returns: The new object.
    func with<V>(_ kp: WritableKeyPath<Self, V>, _ value: V) -> Self
}

public extension With {
    func with<V>(_ kp: WritableKeyPath<Self, V>, _ value: V) -> Self {
        var s = self
        s[keyPath: kp] = value
        return s
    }
}
