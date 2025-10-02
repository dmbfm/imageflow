import Foundation

@MainActor
public protocol Storable {
    associatedtype StorableData: Sendable, Codable

    init(_ data: StorableData)
    func restore(_ snapshot: StorableData)
    func snapshot() -> StorableData
}
