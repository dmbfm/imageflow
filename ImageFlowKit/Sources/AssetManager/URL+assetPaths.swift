import Foundation

extension URL {

    public static var tempAssetsDirectory: URL {
        FileManager.default.temporaryDirectory.appending(path: "ImageFlowAssets")
    }

    public static func tempAssetsDirectory(forDocument id: UUID) -> URL {
        .tempAssetsDirectory.appending(path: id.uuidString)
    }

    public static func tempAssetURL(forDocument id: UUID, filename: String) -> URL {
        .tempAssetsDirectory(forDocument: id).appending(path: filename)
    }
}
