import Foundation

struct RecentDocumentItem: Identifiable, Equatable {
    var id: UUID = .init()
    var url: URL = .init(filePath: "/")
    var name: String
    var path: String
}
