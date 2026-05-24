import Foundation
import SharedModels

public struct PathManager: Sendable {
    let documentInfo: DocumentInfo

    init(_ info: DocumentInfo) {
        self.documentInfo = info
    }

    @discardableResult
    public func ensureAssetsDir() throws -> URL {
        let url = self.assetsDir
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    public var assetsDir: URL {
        FileManager.default
            .imageFlowTemporaryAssetsDirectory
            .appending(path: "\(self.documentInfo.id.uuidString)")
    }

    public func url(forImportingAssetWithID id: UUID, originalURL url: URL) -> URL {
        let ext = url.pathExtension

        if ext.isEmpty {
            return self.assetsDir.appending(path: "\(id.uuidString)")
        } else {
            return self.assetsDir.appending(path: "\(id.uuidString).\(ext)")
        }
    }

    public func url(forImportingAssetWithID id: UUID, originalFilename: String) -> URL {
        let ext = URL(filePath: originalFilename).pathExtension

        if ext.isEmpty {
            return self.assetsDir.appending(path: "\(id.uuidString)")
        } else {
            return self.assetsDir.appending(path: "\(id.uuidString).\(ext)")
        }
    }

    public func url(forReadingAsset asset: Asset) throws(AssetSystemError) -> URL {
        let fm = FileManager.default
        let maybeDocumentAssetsDir = self.documentInfo.url?.appending(path: "Assets")
        let tempAssetsDir = self.assetsDir

        guard let filename = asset.filename else {
            throw .assetNotLoaded
        }

        if let url = maybeDocumentAssetsDir?.appending(path: filename), fm.fileExists(atPath: url.path()) {
            return url
        }

        let url = tempAssetsDir.appending(path: filename)

        if !fm.fileExists(atPath: url.path()) {
            throw .assetFileNotFound
        }

        return url
    }

    public func url(temporaryAssetFileURL asset: Asset) throws(AssetSystemError) -> URL {
        let tempAssetsDir = self.assetsDir

        guard let filename = asset.filename else {
            throw .assetNotLoaded
        }

        return tempAssetsDir.appending(path: filename)
    }
}
