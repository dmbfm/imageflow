import Foundation
import UniformTypeIdentifiers

struct Asset: Identifiable, Equatable, Codable {
    var id: UUID
    var state: AssetState
    var added: Date
    var kind: AssetKind

    var isFileAsset: Bool {
        switch self.state {
        case .loading: true
        case .loaded(let source):
            switch source {
            case .file: true
            case .generated: false
            }
        }
    }

    var isLoaded: Bool {
        switch self.state {
        case .loaded: true
        case .loading: false
        }
    }

    var source: AssetSource? {
        switch self.state {
        case .loading: nil
        case .loaded(let source): source
        }
    }

    var filename: String? {
        self.source?.filename
    }
}

enum AssetKind: Equatable, Codable {
    case image
    case lut

    var utType: UTType {
        switch self {
        case .image: .image
        case .lut: .cubeLut
        }
    }
}

enum AssetState: Equatable, Codable {
    case loading
    case loaded(AssetSource)
}

enum AssetSource: Equatable, Codable {
    case generated(node: UUID, port: Int)
    case file(String)

    var filename: String? {
        switch self {
        case .file(let filename): filename
        case .generated: nil
        }
    }
}
