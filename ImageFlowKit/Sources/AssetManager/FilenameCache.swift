import Foundation
import SharedModels

public struct FilenameCache: Sendable, Equatable, Codable {

    var cache: [UUID: String?] = [:]

    public init() {

    }

    func get(id: UUID) -> String? {
        self.cache[id] ?? nil
    }

    mutating func invalidate() {
        self.cache = [:]
    }

    mutating func removeEntry(id: UUID) {
        self.cache.removeValue(forKey: id)
    }

    mutating func set(id: UUID, filename: String?) {
        self.cache[id] = filename
    }

    mutating func refresh(assets: [UUID: Asset]) {
        self.cache.removeAll(keepingCapacity: true)
        for (id, asset) in assets {
            self.cache[id] = asset.originalFilename
        }
    }
}
