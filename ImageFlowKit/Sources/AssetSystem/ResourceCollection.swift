import Foundation
import SharedModels
import Values

struct ResourceCollection<K, R> where K: Sendable & Hashable {

    var resources: [K: Res<R>] = [:]

    mutating func clear() {
        self.resources.removeAll()
    }

    subscript(_ id: K) -> Res<R>? {
        get {
            self.resources[id]
        }

        set {
            self.resources[id] = newValue
        }
    }

    subscript(_ id: K, default defaultValue: Res<R>) -> Res<R> {
        self.resources[id] ?? defaultValue
    }

    mutating func remove(_ id: K) {
        self.resources.removeValue(forKey: id)
    }
}

extension ResourceCollection: Sendable where R: Sendable {}
