import CoreImage
import CubeLutKit
import Foundation
import SharedModels
import Values

protocol ResourceType<StoredType> {
    associatedtype StoredType: Sendable
    associatedtype Key: Hashable & Sendable
    static func setResource(storage: inout ResourceStorage, id: Key, res: Res<StoredType>?)
    static func getResource(storage: borrowing ResourceStorage, id: Key) -> Res<StoredType>?
}

struct CIImageResourceType: ResourceType<CIImage> {
    static func setResource(storage: inout ResourceStorage, id: Values.AssetIdentifier, res: Res<CIImage>?) {
        storage.images[id] = res
    }

    static func getResource(storage: borrowing ResourceStorage, id: Values.AssetIdentifier) -> Res<CIImage>? {
        storage.images[id]
    }
}

struct LutResourceType: ResourceType<CubeLut> {
    static func setResource(storage: inout ResourceStorage, id: Values.AssetIdentifier, res: Res<CubeLutKit.CubeLut>?) {
        storage.luts[id] = res
    }

    static func getResource(storage: borrowing ResourceStorage, id: Values.AssetIdentifier) -> Res<CubeLutKit.CubeLut>?
    {
        storage.luts[id]
    }
}

public enum ThumbnailResourceKey: Hashable, Sendable {
    case asset(UUID)
    case kind(AssetKind)
}

struct CGImageThumbnailResourceType: ResourceType<CGImage> {

    typealias Key = ThumbnailResourceKey

    static func setResource(storage: inout ResourceStorage, id: Key, res: Res<CGImage>?) {
        switch id {
        case .asset(let id):
            storage.thumbnails[id] = res
        case .kind(let kind):
            storage.assetKindThumbnails[kind] = res
        }
    }

    static func getResource(storage: borrowing ResourceStorage, id: Key) -> Res<CGImage>? {
        switch id {
        case .asset(let id):
            storage.thumbnails[id]
        case .kind(let kind):
            storage.assetKindThumbnails[kind]
        }
    }
}
