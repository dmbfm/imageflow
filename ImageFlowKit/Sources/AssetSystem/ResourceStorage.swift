import CoreImage
import CubeLutKit
import Foundation
import SharedModels
import Values

struct ResourceStorage: ~Copyable {
    var images: ResourceCollection<AssetIdentifier, CIImage> = .init()
    var luts: ResourceCollection<AssetIdentifier, CubeLut> = .init()
    var thumbnails: ResourceCollection<UUID, CGImage> = .init()
    var assetKindThumbnails: ResourceCollection<AssetKind, CGImage> = .init()

    mutating func clear() {
        self = .init()
    }

    mutating func setResource<R: ResourceType>(ofType: R.Type, id: R.Key, res: Res<R.StoredType>?) {
        R.setResource(storage: &self, id: id, res: res)
    }

    func getResource<R: ResourceType>(ofType: R.Type, id: R.Key) -> Res<R.StoredType>? {
        R.getResource(storage: self, id: id)
    }
}
