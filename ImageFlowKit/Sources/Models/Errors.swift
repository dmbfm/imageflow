import Foundation

public struct NodeNotFoundError: Error {

    public var id: UUID?

    public init(id: UUID? = nil) {
        self.id = id
    }
}
