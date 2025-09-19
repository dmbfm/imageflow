import Synchronization

public final class Box<T> {
    public var value: T

    public init(_ value: T) {
        self.value = value
    }
}

public final class UnsafeSendableBox<T>: @unchecked Sendable {
    public var value: T

    public init(_ value: T) {
        self.value = value
    }
}

public final class SendableBox<T>: Sendable where T: Sendable {
    public let value: Mutex<T>

    public init(_ value: T) {
        self.value = .init(value)
    }
}
