import CoreImage
import Foundation
import Helpers
import Logging
import Photos
import PhotosUI
import SwiftUI
import Synchronization
import UniformTypeIdentifiers

actor AssetManager {

    var imageAssets: [UUID: ImageAsset] = [:] {
        didSet {
            if oldValue != self.imageAssets {
                self.emit(.imageAssetsDidChange)
            }
        }
    }

    var thumbs: [UUID: Resource<CGImage, AssetManagerError>] = [:]

    var ciImages: [UUID: Resource<CIImage, AssetManagerError>] = [:]

    var documentInfo: DocumentInfo?

    @MainActor
    var emitter: EventEmitter<Event> = .init()
}

// MARK: - Event

extension AssetManager {
    enum Event {
        case imageAssetsDidChange
    }

    private func emit(_ event: Event) {
        Task { @MainActor in
            log("emit: \(event)", level: .debug)
            self.emitter.emit(event)
        }
    }
}

extension AssetManager {

    func clear() {
        self.imageAssets.removeAll()
        self.thumbs.removeAll()
        self.ciImages.removeAll()
    }

    func restore(_ images: [UUID: ImageAsset]) {
        self.clear()
        for (id, image) in images {
            self.thumbs[id] = .notLoaded
            self.ciImages[id] = .notLoaded
            self.imageAssets[id] = image
        }
    }

    func setDocumentInfo(_ info: DocumentInfo) {
        self.documentInfo = info
    }
}

// MARK: - Image Importing

extension AssetManager {

    /// Import an image from an photo from the user's photo libray, chosen by the user from a `PhotosPicker`.
    ///
    /// - Parameter item: The `PhotosPickerItem` represengint the selected photo.
    /// - Throws:
    /// - Returns: The identifier of the imported asset.
    func addImageAsset(fromPhotosPickerItem item: PhotosPickerItem) async throws(AssetManagerError) -> UUID {
        try await self.addImageAsset { assetsDir in
            guard let identifier = item.itemIdentifier else {
                throw AssetManagerError.assestLoadingError(.photosMissingIdentifier)
            }

            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw AssetManagerError.assestLoadingError(.photosDataIsNil)
            }

            let fetchAssetResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)

            guard let asset = fetchAssetResult.firstObject else {
                throw AssetManagerError.assestLoadingError(.photosMissingIdentifier)
            }

            guard let resource = PHAssetResource.assetResources(for: asset).first else {
                throw AssetManagerError.assestLoadingError(.missingPHAssetResource)
            }

            let filename = resource.originalFilename
            let assetFilename = self.name(forAssetWithFilename: filename)

            try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)
            let assetURL = assetsDir.appending(path: assetFilename)

            try data.write(to: assetURL)

            return assetFilename
        }
    }

    /// Imports an imgage from the givel `URL` as an image asset.
    ///
    /// - Parameter url: The `URL` of the image.
    /// - Throws:
    /// - Returns:
    func addImageAsset(fromURL url: URL) async throws(AssetManagerError) -> UUID {
        try await self.addImageAsset { assetsDir in
            guard url.startAccessingSecurityScopedResource() else {
                throw AssetManagerError.assestLoadingError(.URLAccessError)
            }
            defer { url.stopAccessingSecurityScopedResource() }

            let assetFilename = self.name(forAssetAt: url)
            let assetURL = assetsDir.appending(path: assetFilename)

            try FileManager.default.copyItem(at: url, to: assetURL)

            return assetFilename
        }
    }

    func registerImageAsset(_ asset: ImageAsset) {
        self.imageAssets[asset.id] = asset
        self.thumbs[asset.id] = .notLoaded
        self.ciImages[asset.id] = .notLoaded
    }

    /// A helper used by other `addImageAsset` methods. It takes an optional ID and a `loader` closure, which
    /// takes a `assetsDir` URL, actually does the importing of the asset, and returns the name/filename of
    /// the imported asset. This method then either returns the assets ID or throws an error.
    ///
    /// - Parameters:
    ///   - id: The optional ID of the asset that will be created/imported.
    ///   - loader: The loader closure.
    ///
    /// - Throws:
    /// - Returns: The asset ID.
    private func addImageAsset(
        _ id: UUID = UUID(),
        _ loader: (_ assetsDir: URL) async throws -> String
    ) async throws(AssetManagerError) -> UUID {

        guard let documentID = self.documentInfo?.id else {
            throw .missingDocumentInfo
        }

        let id = UUID()

        self.loadingStart(id)

        do {
            let assetsDir: URL = .tempAssetsDirectory(forDocument: documentID)
            try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)

            let filename = try await loader(assetsDir)

            self.loadingEnd(id, filename: filename)

            return id
        } catch {
            self.loadingCancel(id)
            log("error: \(error)", level: .error)
            if let err = error as? AssetManagerError {
                throw err
            }
            throw .assestLoadingError(.other(error))
        }
    }

    private func loadingStart(_ id: UUID) {
        self.removeImageAsset(id)
        self.registerImageAsset(.init(id: id, state: .loading, added: .now))
    }

    private func loadingEnd(_ id: UUID, filename: String) {
        self.registerImageAsset(
            .init(
                id: id,
                state: .loaded(.file(filename)),
                added: self.imageAssets[id]?.added ?? .now
            )
        )
    }

    private func loadingCancel(_ id: UUID) {
        self.removeImageAsset(id)
    }

    private func name(forAssetAt url: URL) -> String {
        let name = url.lastPathComponent
        let basename = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension

        let names = self.imageAssetNames

        var modifiedName: String? = nil

        if names.contains(name) {
            for i in 2...10000 {
                let attempt = basename + "(\(i))." + ext
                if !names.contains(attempt) {
                    modifiedName = attempt
                    break
                }
            }
        } else {
            return name
        }

        if let modifiedName {
            return modifiedName
        } else {
            return basename + "\(UUID().uuidString)." + ext
        }
    }

    private func name(forAssetWithFilename name: String) -> String {
        self.name(forAssetAt: .init(filePath: name))
    }

    private var imageAssetNames: [String] {
        self.imageAssets.values.compactMap { asset in
            switch asset.state {
            case .loading:
                nil
            case .loaded(let source):
                switch source {
                case .file(let filename): filename
                case .generated: nil
                }
            }
        }
    }
}

// MARK: - Asset Deletion

extension AssetManager {
    @discardableResult
    func removeImageAsset(_ id: UUID) -> ImageAsset? {
        self.thumbs[id] = nil
        self.ciImages[id] = nil
        return self.imageAssets.removeValue(forKey: id)
    }
}


// MARK: - Load Image Representations for Assets 

extension AssetManager {
    func getThumb(forImageAsset id: UUID) async throws(AssetManagerError) -> CGImage {
        guard let asset = self.imageAssets[id] else {
            throw AssetManagerError.thumbnailLoadingError(.assetNotFound(id))
        }

        let res = self.thumbs[id, default: .notLoaded]

        guard asset.state != .loading else {
            throw .thumbnailLoadingError(.assetStillLoading(id))
        }

        let fm = FileManager.default

        var task: Task<CGImage, any Error>? = nil

        switch res {
        case .failed(let err):
            throw err
        case .loaded(let image):
            return image
        case .loading(let t):
            task = t
        case .notLoaded:
            task = Task { try await doLoad() }
            self.thumbs[id] = .loading(task!)
        }

        do {
            let value = try await task!.value
            self.thumbs[id] = .loaded(value)
            return value
        } catch {
            if let err = error as? AssetManagerError {
                self.thumbs[id] = .failed(err)
                throw err
            } else {
                self.thumbs[id] = .failed(.thumbnailLoadingError(.other(error)))
                throw .thumbnailLoadingError(.other(error))
            }
        }

        func doLoad() async throws(AssetManagerError) -> CGImage {
            precondition(asset.source != nil)
            switch asset.source {
            case .file(let filename):
                return try await doLoadFile(filename: filename)
            case .generated:
                fatalError("TODO: Not implemented")
            case .none:
                fatalError("Missing source (unreachable)")
            }
        }

        func doLoadFile(filename: String) async throws(AssetManagerError) -> CGImage {
            let maybeDocumentImageURL = self.documentAssetURL(filename: filename)

            let tempImageURL = self.tempAssetURL(filename: filename)!

            let imageURL =
                if let documentImageURL = maybeDocumentImageURL, fm.fileExists(atPath: documentImageURL.path) {
                    documentImageURL
                } else if fm.fileExists(atPath: tempImageURL.path) {
                    tempImageURL
                } else {
                    throw AssetManagerError.thumbnailLoadingError(
                        .fileNotFound(document: maybeDocumentImageURL, temp: tempImageURL)
                    )
                }

            let opts =
                [
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceShouldCacheImmediately: true,
                    kCGImageSourceThumbnailMaxPixelSize: 256,
                ] as CFDictionary
            guard
                let source = CGImageSourceCreateWithURL(
                    imageURL as CFURL,
                    [kCGImageSourceShouldCache: false] as CFDictionary
                )
            else {
                throw AssetManagerError.thumbnailLoadingError(.cgImageSourceCreateWithURLError)
            }

            guard let thumb = CGImageSourceCreateThumbnailAtIndex(source, 0, opts) else {
                throw AssetManagerError.thumbnailLoadingError(.cgImageSourceCreateThumbnailError)
            }

            return thumb
        }
    }
}


// MARK: - URLs

extension AssetManager {
    private func tempAssetURL(filename: String) -> URL? {
        if let id = self.documentInfo?.id {
            .tempAssetURL(forDocument: id, filename: filename)
        } else {
            nil
        }
    }

    private func documentAssetURL(filename: String) -> URL? {
        self.documentInfo?.url?.appending(path: "Assets").appending(path: filename)
    }
}
