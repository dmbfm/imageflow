import CoreImage
import Foundation
import Helpers
import Logging
import Synchronization

actor AssetManager {

    // MARK: - Exposed Properties

    var imageAssets: [UUID: ImageAsset] = [:] {
        didSet {
            if oldValue != self.imageAssets {
                self.emit(.imageAssetsDidChange)
            }
        }
    }

    var thumbs: [UUID: Resource<CGImage, AssetManagerError.ThumbError>] = [:]

    var ciImages: [UUID: Resource<CIImage, ()>] = [:]

    var documentInfo: DocumentInfo?

    @MainActor
    var emitter: EventEmitter<Event> = .init()

    // MARK: -  Private Properties

    private var imageAssetNames: [String] {
        self.imageAssets.values.compactMap {
            switch $0.source {
            case .file(let name): name
            default: nil
            }
        }
    }

    // MARK: - Exposed Types

    enum Event {
        case imageAssetsDidChange
    }

    // MARK: - Exposed Methods

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

    // MARK: Assset Management

    func addImageAsset(fromURL url: URL, overrideID: UUID? = nil) async throws -> UUID {

        guard let documentID = self.documentInfo?.id else {
            throw AssetManagerError.missingBaseURL
        }

        guard url.startAccessingSecurityScopedResource() else {
            throw AssetManagerError.accessError
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let assetsDir: URL = .tempAssetsDirectory(forDocument: documentID)
        try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)

        let assetFilename = self.name(forAssetAt: url)
        let assetURL = assetsDir.appending(path: assetFilename)

        try FileManager.default.copyItem(at: url, to: assetURL)

        let id = overrideID ?? UUID()

        self.imageAssets[id] = .init(
            id: id,
            source: .file(assetFilename),
            added: .now,
            res: .init(thumb: .notLoaded, ciImage: .notLoaded)
        )
        self.thumbs[id] = .notLoaded
        self.ciImages[id] = .notLoaded

        return id
    }

    func registerImage(_ asset: ImageAsset) {
        self.imageAssets[asset.id] = asset
    }

    func removeImage(_ id: UUID) -> ImageAsset? {
        self.imageAssets.removeValue(forKey: id)
    }

    func getThumb(forImageAsset id: UUID) async throws -> CGImage {
        guard let asset = self.imageAssets[id] else {
            throw AssetManagerError.missingImageAsset(id)
        }
        guard let res = self.thumbs[id] else {
            throw AssetManagerError.missingThumbResource(id)
        }

        let fm = FileManager.default

        var task: Task<CGImage, any Error>? = nil

        switch res {
        case .failed(let err):
            throw err
        case .loaded(let image):
            log("returning cached image!", level: .debug)
            return image
        case .loading(let t):
            task = t
        case .notLoaded:
            task = Task { try await doLoad() }
            self.setThumbResource(id, .loading(task!))
        }

        do {
            let value = try await task!.value
            self.setThumbResource(id, .loaded(value))
            return value
        } catch {
            self.setThumbResource(id, .failed(.createThumbFailed))
            throw AssetManagerError.thumbCreation(.createThumbFailed)
        }

        func doLoad() async throws -> CGImage {
            switch asset.source {
            case .file(let filename):
                try await doLoadFile(filename: filename)
            case .generated:
                fatalError("TODO: Not implemented")
            }
        }

        func doLoadFile(filename: String) async throws -> CGImage {
            let maybeDocumentImageURL = self.documentAssetURL(filename: filename)

            let tempImageURL = self.tempAssetURL(filename: filename)!

            let imageURL =
                if let documentImageURL = maybeDocumentImageURL, fm.fileExists(atPath: documentImageURL.path) {
                    documentImageURL
                } else if fm.fileExists(atPath: tempImageURL.path) {
                    tempImageURL
                } else {
                    throw AssetManagerError.thumbCreation(.createThumbFailed)
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
                throw AssetManagerError.thumbCreation(.imageSourceCreationFailed)
            }

            guard let thumb = CGImageSourceCreateThumbnailAtIndex(source, 0, opts) else {
                throw AssetManagerError.thumbCreation(.createThumbFailed)
            }

            return thumb
        }
    }

    // MARK: - Private Methods

    private func setThumbResource(_ id: UUID, _ res: Resource<CGImage, AssetManagerError.ThumbError>) {
        self.thumbs[id] = res
        self.imageAssets[id]?.res.thumb = res.state
    }

    private func emit(_ event: Event) {
        Task { @MainActor in
            self.emitter.emit(event)
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
