import Foundation
import SharedModels
import Values

struct ResourceCollection<R> {

    typealias Res<T> = Resource<T, AssetStoreServiceError>

    var resources: [UUID: Res<R>] = [:]

    mutating func clear() {
        self.resources.removeAll()
    }

    subscript(_ id: UUID) -> Res<R>? {
        get {
            self.resources[id]
        }

        set {
            self.resources[id] = newValue
        }
    }

    subscript(_ id: UUID, default defaultValue: Res<R>) -> Res<R> {
        self.resources[id] ?? defaultValue
    }
}

extension ResourceCollection: Sendable where R: Sendable {}
