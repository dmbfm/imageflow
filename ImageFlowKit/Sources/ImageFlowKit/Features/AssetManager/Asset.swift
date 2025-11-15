import Foundation
import UniformTypeIdentifiers
import Values
import Helpers

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

struct  GeneratedResource<T>: Identifiable {
    var id: OutputPortLocation
    var timestamp: Date
    var res: T
}

extension GeneratedResource: Sendable where T: Sendable {}

// struct Asset: Identifiable, Equatable, Codable {
//     var id: AssetIdentifier
//     var state: AssetState
//     var added: Date
//     var kind: AssetKind

//     var isFileAsset: Bool {
//         switch self.state {
//         case .loading: true
//         case .loaded(let source):
//             switch source {
//             case .file: true
//             case .generated: false
//             }
//         }
//     }

//     var isLoaded: Bool {
//         switch self.state {
//         case .loaded: true
//         case .loading: false
//         }
//     }

//     var source: AssetSource? {
//         switch self.state {
//         case .loading: nil
//         case .loaded(let source): source
//         }
//     }

//     var filename: String? {
//         self.source?.filename
//     }

//     func isGenerated(byNode id: UUID) -> Bool {
//         switch self.id {
//             case .uuid(_): false
//             case .nodeOutput(let node, _): node == id
//         }
//     }

//     func isGenerated(byPort loc: OutputPortLocation) -> Bool {
//         switch self.id {
//             case .uuid(_): false
//             case let .nodeOutput(node, port): OutputPortLocation(node: node, index: port) == loc
//         }
//     }
// }


// enum AssetState: Equatable, Codable {
//     case loading
//     case loaded(AssetSource)
// }

// enum AssetSource: Equatable, Codable {
//     case generated
//     case file(String)

//     var filename: String? {
//         switch self {
//         case .file(let filename): filename
//         case .generated: nil
//         }
//     }
// }
