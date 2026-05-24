import Foundation

public extension FileManager {
    var imageFlowTemporaryAssetsDirectory: URL {
        self.temporaryDirectory.appending(path: GlobalConstants.tempAssetsDirName)
    }
}
