import Combine
import Foundation

/// The `Rx` protocol provides helper methods (via default implementations) to implement
/// reactive updates of object properties.
public protocol Rx: AnyObject {
    /// Thes storage for `Cacellable`s.
    var cancellables: Set<AnyCancellable> { get set }
    /// The default implementation subscribes to the given `Publisher`, setting
    /// the keypath `kp` when a value is received.
    /// - Parameters:
    ///   - publisher: The publisher from which values will be received.
    ///   - kp: The key-path (`ReferenceWritableKeyPath`) that defines which property will be
    ///         mutated by setting it with the received values.
    ///
    /// - Returns: A reference to Self.
    func rx<V>(_ publisher: any Publisher<V, Never>, kp: ReferenceWritableKeyPath<Self, V>) -> Self
    /// The default implementation subscribes to the given `Publisher`, applying received values using
    /// the `setter` closure.
    /// - Parameters:
    ///   - publisher: The publisher from which values will be received.
    ///   - setter: A closure that is called when a new value is received.
    ///
    /// - Returns:
    func rx<V>(_ publisher: any Publisher<V, Never>, setter: @escaping (Self, V) -> ()) -> Self
}

public extension Rx {
    @discardableResult
    func rx<V>(_ publisher: any Publisher<V, Never>, kp: ReferenceWritableKeyPath<Self, V>) -> Self {
        publisher
            .sink { [weak self] in self?[keyPath: kp] = $0 }
            .store(in: &self.cancellables)
        return self
    }

    @discardableResult
    func rx<V>(_ publisher: any Publisher<V, Never>, setter: @escaping (Self, V) -> ()) -> Self {
        publisher
            .sink { [weak self] value in self.map({ setter($0, value) }) }
            .store(in: &self.cancellables)
        return self
    }
}
