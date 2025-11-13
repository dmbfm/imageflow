import Foundation
import UniformTypeIdentifiers
import Values

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

    var valueType: ValueType? {
        switch self {
        case .image: .image
        case .lut: .lut
        }
    }
}

enum AssetState: Equatable, Codable {
    case loading
    case loaded(AssetSource)
}

enum AssetSource: Equatable, Codable {
    case generated(OutputPortLocation)
    case file(String)

    var filename: String? {
        switch self {
        case .file(let filename): filename
        case .generated: nil
        }
    }
}
