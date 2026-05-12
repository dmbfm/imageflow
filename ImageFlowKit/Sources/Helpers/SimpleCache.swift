import Foundation

public class SimpleCache<ID: Hashable, V: Sendable> {
    private var items: [ID: V] = [:]
    private var locked: Bool = false

    public init() {}

    public func clear() {
        self.items.removeAll()
    }

    public func set(_ id: ID, _ value: V) {
        if !self.locked {
            print("set: \(id) -> \(value)")
            self.items[id] = value
        }
    }

    public func get(_ id: ID) -> V? {
        self.items[id]
    }

    public func lock() {
        self.locked = true
    }

    public func unlock() {
        self.locked = false
    }

    public func whileLocked(_ perform: () -> ()) {
        self.lock()
        perform()
        self.unlock()
    }
}
