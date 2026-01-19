import Foundation

public struct DocumentInfo: Sendable, Equatable, Codable {
    public var id: UUID
    public var url: URL?

    public init(id: UUID, url: URL? = nil) {
        self.id = id
        self.url = url
    }
}
