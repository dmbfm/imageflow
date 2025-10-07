import CoreImage
import Foundation

struct ImageAsset: Identifiable, Equatable, Codable {
    var id: UUID
    var source: Source
    var added: Date

    enum Source: Equatable, Codable {
        case generated(node: UUID, port: Int)
        case file(String)

        var isFile: Bool {
            if case .file = self {
                true
            } else {
                false
            }
        }

        var filename: String? {
            if case let .file(filename) = self {
                filename
            } else {
                nil
            }
        }
    }
}
