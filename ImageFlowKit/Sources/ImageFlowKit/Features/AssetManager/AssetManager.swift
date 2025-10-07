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

    var documentInfo: DocumentInfo?

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

    func reset() {
        self.imageAssets = [:]
        self.thumbs = [:]
        self.ciImages = [:]
    }

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

    private var imageAssetNames: [String] {
        self.imageAssets.values.compactMap {
            switch $0.source {
            case .file(let name): name
            default: nil
            }
        }
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

    static var tempAssetsDirectory: URL {
        FileManager.default.temporaryDirectory.appending(path: "ImageFlowAssets")
    }

    static func tempAssetsDirectory(forDocument id: UUID) -> URL {
        Self.tempAssetsDirectory.appending(path: id.uuidString)
    }

    static func tempAssetURL(documentID id: UUID, filename: String) -> URL {
        Self.tempAssetsDirectory.appending(path: id.uuidString).appending(path: filename)
    }

    func addImageAsset(fromURL url: URL) async throws -> UUID {

        guard let documentID = self.documentInfo?.id else {
            throw AssetManagerError.missingBaseURL
        }

        guard url.startAccessingSecurityScopedResource() else {
            throw AssetManagerError.accessError
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let assetsDir = Self.tempAssetsDirectory(forDocument: documentID)
        try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)

        let assetFilename = self.name(forAssetAt: url)
        let assetURL = assetsDir.appending(path: assetFilename)

        try FileManager.default.copyItem(at: url, to: assetURL)

        let id = UUID()

        self.imageAssets[id] = .init(id: id, source: .file(assetFilename), added: .now)
        self.thumbs[id] = .notLoaded
        self.ciImages[id] = .notLoaded

        return id
    }

    func getThumb(forImageAsset id: UUID) async throws -> CGImage {
        guard let asset = self.imageAssets[id] else {
            throw AssetManagerError.missingImageAsset(id)
        }
        guard let res = self.thumbs[id] else {
            throw AssetManagerError.missingThumbResource(id)
        }
        if case let .loaded(image) = res {
            return image
        }
        guard let documentInfo = self.documentInfo else {
            throw AssetManagerError.missingBaseURL
        }

        let fm = FileManager.default

        if case let .file(filename) = asset.source {

            let maybeDocumentImageURL = documentInfo.url?.appending(path: "Assets").appending(path: filename)
            let tempImageURL = Self.tempAssetsDirectory(forDocument: documentInfo.id).appending(path: filename)

            let imageURL =
                if let documentImageURL = maybeDocumentImageURL, fm.fileExists(atPath: documentImageURL.path) {
                    documentImageURL
                } else if fm.fileExists(atPath: tempImageURL.path) {
                    tempImageURL

                } else {
                    fatalError()
                }

            self.thumbs[id] = .loading
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
                self.thumbs[id] = .failed(.imageSourceCreationFailed)
                throw AssetManagerError.thumbCreation(.imageSourceCreationFailed)
            }

            guard let thumb = CGImageSourceCreateThumbnailAtIndex(source, 0, opts) else {
                self.thumbs[id] = .failed(.createThumbFailed)
                throw AssetManagerError.thumbCreation(.createThumbFailed)
            }

            self.thumbs[id] = .loaded(thumb)

            return thumb

        } else {
            fatalError()
        }
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
