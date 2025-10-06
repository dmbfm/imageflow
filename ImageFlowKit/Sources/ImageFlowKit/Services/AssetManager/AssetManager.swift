import CoreImage
import Foundation
import Synchronization

actor AssetManager {

    public var images: [UUID: ImageAsset] = [:]

    public var baseURL: URL? = nil

    func addImageAsset(fromURL url: URL) throws -> UUID {

        guard let baseURL else {
            throw AssetManagerError.missingBaseURL
        }

        let dest = baseURL.appending(path: url.lastPathComponent)

        try FileManager.default.copyItem(at: url, to: dest)

        guard let ciImage = CIImage(contentsOf: dest, options: [.applyOrientationProperty: true]) else {
            throw AssetManagerError.ciImageCreateError
        }

        let id = UUID()
        self.images[id] = .init(source: .file(dest.lastPathComponent), ciImage: ciImage)

        return id
    }

    func addImageAsset(fromGeneratedImage ciImage: CIImage, id: UUID) {
        self.images[id] = .init(source: .generated, ciImage: ciImage)
    }
}

enum AssetManagerError: Error {
    case missingBaseURL
    case ciImageCreateError
}

struct ImageAsset {
    var source: Source
    var ciImage: CIImage

    enum Source {
        case generated
        case file(String)
    }
}

// public actor AssetManager {
// 	var documentAssetProvider: SomeStorageContainer = .init()

// 	func f() {
// 		self.documentAssetProvider.storage.withLock { _ in }
// 	}
// }

// protocol DocumentAssetProviderProtocol: AnyObject {
// 	var assets: Mutex<Data>  { get }
// }
