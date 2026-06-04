import Foundation
import Helpers
import UniformTypeIdentifiers
import Values

public struct Asset: Sendable, Identifiable, Equatable, Codable, With {
    public var id: UUID
    public var kind: AssetKind
    public var timestamp: Date
    public var state: AssetState

    public init(id: UUID, kind: AssetKind, timestamp: Date, state: AssetState) {
        self.id = id
        self.kind = kind
        self.timestamp = timestamp
        self.state = state
    }

    public var filename: String? {
        if case let .loaded(filename: name, _) = self.state {
            name
        } else {
            nil
        }
    }

    public var originalFilename: String? {
        switch self.state {
        case .loaded(_, let originalFilename): originalFilename
        case .loading(let originalFilename): originalFilename
        }
    }

    public var isLoaded: Bool {
        if case .loaded = self.state {
            true
        } else {
            false
        }
    }
}

public enum AssetState: Sendable, Equatable, Codable {
    case loading(originalFilename: String?)
    case loaded(filename: String, originalFilename: String)
}

public enum AssetKind: Sendable, Equatable, Codable {
    case image
    case lut

    public var valueType: ValueType? {
        switch self {
        case .image: .image
        case .lut: .lut
        }
    }

    public var displayName: String {
        switch self {
        case .image: "image"
        case .lut: "LUT"
        }
    }
}

public extension ValueType {
    var assetKind: AssetKind? {
        switch self {
        case .image: .image
        case .lut: .lut
        default: nil
        }
    }
}
