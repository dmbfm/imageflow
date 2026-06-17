import Combine

extension Publisher {
    /// A safe `assign` method that does not retain string references to the target object.
    /// - Parameters:
    ///   - target: The target object.
    ///   - kp: The key-path on the target-object.
    ///
    /// - Returns: The cancellable object.
    public func assign<Root>(_ target: Root, _ kp: ReferenceWritableKeyPath<Root, Output>) -> AnyCancellable
    where Failure == Never, Root: AnyObject {
        self.sink { [weak target] value in
            target?[keyPath: kp] = value
        }
    }
    /// A safe `assign` method that does not retain string references to the target object.
    /// - Parameters:
    ///   - target: The target object.
    ///   - kp: The key-path on the target-object.
    ///
    /// - Returns: The cancellable object.
    public func assignMap<Root>(_ target: Root, _ kp: ReferenceWritableKeyPath<Root, Output>) -> AnyCancellable
    where Failure == Never, Root: AnyObject {
        self.sink { [weak target] value in
            target?[keyPath: kp] = value
        }
    }
}
