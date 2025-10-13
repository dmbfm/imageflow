import Foundation

extension URL {

    static var tempAssetsDirectory: URL {
        FileManager.default.temporaryDirectory.appending(path: "ImageFlowAssets")
    }

    static func tempAssetsDirectory(forDocument id: UUID) -> URL {
        .tempAssetsDirectory.appending(path: id.uuidString)
    }

    static func tempAssetURL(forDocument id: UUID, filename: String) -> URL {
        .tempAssetsDirectory(forDocument: id).appending(path: filename)
    }
}
