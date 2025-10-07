import CoreImage
import Foundation
import Helpers
import Logging
import Synchronization

actor AssetManager {

    var imageAssets: [UUID: ImageAsset] = [:] {
        didSet {
            log("imageAssets didSet")
            if oldValue != self.imageAssets {
                log("emit!")
                self.emit(.imageAssetsDidChange)
            }
        }
    }

    var thumbs: [UUID: ResourceState<CGImage, AssetManagerError.ThumbError>] = [:] {
        didSet {
            if oldValue != self.thumbs {
                self.emit(.thumbsDidChange)
            }
        }
    }

    var ciImages: [UUID: ResourceState<CIImage, ()>] = [:]

    var documentID: UUID?

    @MainActor
    var emitter: EventEmitter<Event> = .init()

    enum Event {
        case imageAssetsDidChange
        case thumbsDidChange
    }

    func emit(_ event: Event) {
        Task { @MainActor in
            self.emitter.emit(event)
        }
    }

    func setDocumentID(_ id: UUID) {
        self.documentID = id
    }

    func getThumb(forImageAsset id: UUID) async throws -> CGImage {
        guard let asset = self.imageAssets[id] else {
            throw AssetManagerError.missingImageAsset(id)
        }
        guard let res = self.thumbs[id] else {
            throw AssetManagerError.missingThumbResource(id)
        }
        guard let documentID = self.documentID else {
            throw AssetManagerError.missingBaseURL
        }

        let assetsDir = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appending(path: documentID.uuidString)
        try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)

        switch res {
        case .failed(_): fatalError()
        case .notLoaded, .loading:
            switch asset.source {
            case .file(.temp(let filename)), .file(.document(let filename)):
                self.thumbs[id] = .loading
                let url = assetsDir.appending(path: filename)
                let opts =
                    [
                        kCGImageSourceCreateThumbnailWithTransform: true,
                        kCGImageSourceCreateThumbnailFromImageAlways: true,
                        kCGImageSourceShouldCacheImmediately: true,
                        kCGImageSourceThumbnailMaxPixelSize: 256,
                    ] as CFDictionary
                guard
                    let source = CGImageSourceCreateWithURL(
                        url as CFURL,
                        [kCGImageSourceShouldCache: false] as CFDictionary
                    )
                else {
                    self.thumbs[id] = .failed(.imageSourceCreationFailed)
                    throw AssetManagerError.thumbCreation(.imageSourceCreationFailed)
                }

                guard let thumb = CGImageSourceCreateThumbnailAtIndex(source, 0, opts) else {
                    self.thumbs[id] = .failed(.createThumbFailed)
                    throw AssetManagerError.thumbCreation(.createThumbFailed)
                }

                self.thumbs[id] = .loaded(thumb)

                return thumb
            case .generated:
                fatalError("TODO: Implement thumbnail creation for generated image?")
            }
        case .loaded(let thumb): return thumb
        }
    }

    func addImageAsset(fromURL url: URL) async throws -> UUID {

        guard let documentID = self.documentID else {
            throw AssetManagerError.missingBaseURL
        }

        guard url.startAccessingSecurityScopedResource() else {
            throw AssetManagerError.accessError
        }

        defer { url.stopAccessingSecurityScopedResource() }

        let assetsDir = FileManager.default.temporaryDirectory.appending(path: "ImageFlowAssets").appending(
            path: documentID.uuidString
        )
        try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)

        let assetFilename = url.lastPathComponent
        let assetURL = assetsDir.appending(path: assetFilename)

        try FileManager.default.copyItem(at: url, to: assetURL)

        let id = UUID()

        self.imageAssets[id] = .init(id: id, source: .file(.temp(assetFilename)), added: .now)
        self.thumbs[id] = .notLoaded
        self.ciImages[id] = .notLoaded

        return id
    }
}

enum AssetManagerError: Error, Equatable {
    case missingBaseURL
    case ciImageCreateError
    case accessError
    case missingImageAsset(UUID)
    case missingThumbResource(UUID)
    case thumbCreation(ThumbError)

    enum ThumbError: Error, Equatable {
        case imageSourceCreationFailed
        case createThumbFailed
    }
}
