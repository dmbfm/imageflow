@MainActor
public final class EventEmitter<T> {
    private var listeners: [(T) -> ()] = []

    public init() {

    }

    public func on(_ listener: @escaping (T) -> ()) {
        self.listeners.append(listener)
    }

    public func emit(_ event: T) {
        for listener in self.listeners {
            listener(event)
        }
    }

    public func clear() {
        self.listeners = []
    }
}
