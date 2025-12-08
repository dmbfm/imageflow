import Foundation
import Helpers
import UniformTypeIdentifiers
import Values

struct Asset: Identifiable, Equatable, Codable, With {
    var id: UUID
    var kind: AssetKind
    var timestamp: Date
    var state: AssetState

    var filename: String? {
        if case let .loaded(filename: name) = self.state {
            name
        } else {
            nil
        }
    }

    var isLoaded: Bool {
        if case .loaded = self.state {
            true
        } else {
            false
        }
    }
}

enum AssetState: Equatable, Codable {
    case loading
    case loaded(filename: String)
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

struct GeneratedResource<T>: Identifiable {
    var id: OutputPortLocation
    var timestamp: Date
    var res: T
}

extension GeneratedResource: Sendable where T: Sendable {}
