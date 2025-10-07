import CoreImage
import Foundation

struct ImageAsset: Identifiable, Equatable, Codable {
    var id: UUID
    var source: Source
    var added: Date

    enum Source: Equatable, Codable {
        case generated(node: UUID, port: Int)
        case file(FileLocation)

        var isFile: Bool {
            if case .file = self {
                true
            } else {
                false
            }
        }

        enum FileLocation: Equatable, Codable {
            case temp(String)
            case document(String)
        }
    }
}
