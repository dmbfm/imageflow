import Foundation

public struct RecentDocumentItem: Identifiable, Equatable {
    public init(id: UUID = .init(), url: URL = .init(filePath: "/"), name: String, path: String) {
        self.id = id
        self.url = url
        self.name = name
        self.path = path
    }

    public var id: UUID = .init()
    public var url: URL = .init(filePath: "/")
    public var name: String
    public var path: String
}
