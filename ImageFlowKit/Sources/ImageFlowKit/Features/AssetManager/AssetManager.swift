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

    // MARK: - Exposed Properties

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

    // MARK: - Exposed Types

    enum Event {
        case imageAssetsDidChange
    }

    // MARK: -  Private Properties

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

    // MARK: - Exposed Methods

    func restore(_ images: [UUID: ImageAsset]) {
        for (id, image) in images {
            self.thumbs[id] = .notLoaded
            self.ciImages[id] = .notLoaded
            self.imageAssets[id] = image
        }
    }

    func setDocumentInfo(_ info: DocumentInfo) {
        self.documentInfo = info
    }

    // MARK: Assset Management

    func addImageAsset(fromPhotosPickerItem item: PhotosPickerItem) async throws(AssetManagerError) -> UUID {
        guard let documentID = self.documentInfo?.id else {
            throw .missingDocumentInfo
        }

        let id = UUID()

        self.loadingStart(id)

        do {

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

            let assetsDir: URL = .tempAssetsDirectory(forDocument: documentID)
            try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)
            let assetURL = assetsDir.appending(path: assetFilename)

            try data.write(to: assetURL)

            self.loadingEnd(id, filename: assetFilename)

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

    func addImageAsset(fromURL url: URL) async throws(AssetManagerError) -> UUID {
        guard let documentID = self.documentInfo?.id else {
            throw AssetManagerError.missingDocumentInfo
        }

        let id = UUID()

        self.loadingStart(id)

        do {
            guard url.startAccessingSecurityScopedResource() else {
                throw AssetManagerError.assestLoadingError(.URLAccessError)
            }
            defer { url.stopAccessingSecurityScopedResource() }

            let assetsDir: URL = .tempAssetsDirectory(forDocument: documentID)
            try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)

            let assetFilename = self.name(forAssetAt: url)
            let assetURL = assetsDir.appending(path: assetFilename)

            try FileManager.default.copyItem(at: url, to: assetURL)

            self.loadingEnd(id, filename: assetFilename)

            return id
        } catch {
            self.loadingCancel(id)

            if let err = error as? AssetManagerError {
                throw err
            } else {
                throw .assestLoadingError(.other(error))
            }
        }
    }

    func registerImageAsset(_ asset: ImageAsset) {
        self.imageAssets[asset.id] = asset
        self.thumbs[asset.id] = .notLoaded
        self.ciImages[asset.id] = .notLoaded
    }

    @discardableResult
    func removeImageAsset(_ id: UUID) -> ImageAsset? {
        self.thumbs[id] = nil
        self.ciImages[id] = nil
        return self.imageAssets.removeValue(forKey: id)
    }

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

    // MARK: - Private Methods

    private func emit(_ event: Event) {
        Task { @MainActor in
            log("emit: \(event)", level: .debug)
            self.emitter.emit(event)
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
            for i in 1...10000 {
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

    // MARK: - URLs

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
