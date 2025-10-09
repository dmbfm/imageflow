import CoreImage
import Foundation

struct ImageAsset: Identifiable, Equatable, Codable {
    var id: UUID
    var source: Source
    var added: Date
    var res: Resources

    struct Resources: Equatable, Codable {
        var thumb: ResourceState
        var ciImage: ResourceState
    }

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
