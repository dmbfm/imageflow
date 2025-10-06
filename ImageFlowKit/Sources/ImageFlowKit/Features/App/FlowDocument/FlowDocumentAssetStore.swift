import Foundation
import Synchronization

final class FlowDocumentAssetStoreContainer: @unchecked Sendable {
    public let store: Mutex<FlowDocumentAssetStore>

    init(_ store: FlowDocumentAssetStore) {
        self.store = .init(store)
    }
}

struct FlowDocumentAssetStore: Sendable {
    static let testData: Data = {
        let arr: [UInt8] = .init(repeating: 0xAF, count: 512)
        return .init(arr)
    }()
    var assets: [UUID: FlowDocumentAsset] = [
        .init(): .init(metadata: .init(name: "TestAsset", kind: .image), data: Self.testData)
    ]

    var metadataMap: MetadataMap {
        .init(metadata: .init(uniqueKeysWithValues: self.assets.map { (k, v) in (k, v.metadata) }))
    }

    struct MetadataMap: Sendable, Codable {
        var metadata: [UUID: FlowDocumentAsset.Metadata] = [:]
    }
}

struct FlowDocumentAsset: Sendable {
    var metadata: Metadata
    var data: Data

    struct Metadata: Sendable, Codable {
        var name: String
        var kind: Kind
    }

    enum Kind: Sendable, Codable {
        case image
    }
}

