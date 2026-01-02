import Foundation

public final class EventEmitter<T> {

    private var listeners: [Int: (T) -> ()] = [:]
    private var counter: Int = 0

    public typealias Handle = Int

    public final class Cancellable: EventEmitterCancellable {
        private weak var emitter: EventEmitter<T>?
        private var handle: Handle

        public var anyCancellable: AnyEventEmitterCancellable {
            .init(value: self)
        }

        public func store(in storage: inout Set<AnyEventEmitterCancellable>) {
            storage.insert(.init(value: self))
        }

        init(_ emitter: EventEmitter<T>, _ handle: Handle) {
            self.emitter = emitter
            self.handle = handle
        }

        deinit {
            self.emitter?.off(self.handle)
        }
    }

    public init() {

    }

    public func on(_ listener: @escaping (T) -> ()) -> AnyEventEmitterCancellable {
        defer { self.counter += 1 }
        self.listeners[self.counter] = listener
        return .init(value: Cancellable(self, self.counter))
    }

    private func off(_ handle: Handle) {
        self.listeners.removeValue(forKey: handle)
    }

    public func emit(_ event: T) {
        for (_, listener) in self.listeners {
            listener(event)
        }
    }

    public func clear() {
        self.listeners = [:]
    }
}

public protocol EventEmitterCancellable: AnyObject {}

public class AnyEventEmitterCancellable: Hashable {
    public static func == (lhs: AnyEventEmitterCancellable, rhs: AnyEventEmitterCancellable) -> Bool {
        lhs.hash == rhs.hash
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.hash)
    }

    var value: any EventEmitterCancellable
    var hash: ObjectIdentifier

    init(value: some EventEmitterCancellable) {
        self.hash = ObjectIdentifier(value)
        self.value = value
    }

    public func store(in storage: inout Set<AnyEventEmitterCancellable>) {
        storage.insert(self)
    }
}
