import Foundation

@MainActor
public protocol Storable {
    associatedtype StorableData: Sendable, Codable

    init(_ data: StorableData)
    func snapshot() async throws -> StorableData
}
