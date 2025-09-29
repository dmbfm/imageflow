import Foundation

public struct Filepath: Sendable, Hashable, Codable {
    public var url: URL?

    public init(_ url: URL? = nil) {
        self.url = url
    }
}
