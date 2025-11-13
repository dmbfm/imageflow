import Backend
import CoreImage
import CubeLutKit
import Foundation
import Helpers
import Logging
import Photos
import PhotosUI
import SwiftUI
import Synchronization
import UniformTypeIdentifiers
import Values

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

actor AssetManager {
    var assets: [UUID: Asset] = [:] {
        didSet {
            if oldValue != self.assets {
                self.emit(.assetsDidChange)
            }
        }
    }

    var luts: [UUID: Resource<CubeLut, AssetManagerError>] = [:]
    var thumbs: [UUID: Resource<CGImage, AssetManagerError>] = [:]
    var ciImages: [UUID: Resource<CIImage, AssetManagerError>] = [:]
    var assetKindThumbs: [AssetKind: Resource<CGImage, AssetManagerError>] = [:]
    var nodeAssetIdMap: [OutputPortLocation: UUID] = [:]
    var documentInfo: DocumentInfo?

    @MainActor
    var emitter: EventEmitter<Event> = .init()
}

extension AssetManager {
    func assets(ofKind kind: AssetKind) -> [Asset] {
        self.assets.values.filter({ $0.kind == kind })
    }

    var imageAssets: [Asset] {
        self.assets(ofKind: .image)
    }

    var lutAssets: [Asset] {
        self.assets(ofKind: .lut)
    }
}

// MARK: - Event

extension AssetManager {
    enum Event {
        case assetsDidChange
    }

    private func emit(_ event: Event) {
        Task { @MainActor in
            self.emitter.emit(event)
        }
    }
}

extension AssetManager {
    func clear() {
        self.assets.removeAll()
        self.thumbs.removeAll()
        self.ciImages.removeAll()
        self.luts.removeAll()
        self.nodeAssetIdMap.removeAll()
    }

    func restore(_ assets: [UUID: Asset]) {
        self.clear()
        for (id, asset) in assets {
            self.assets[id] = asset
            switch asset.kind {
            case .image:
                self.thumbs[id] = .notLoaded
                self.ciImages[id] = .notLoaded
            case .lut:
                self.luts[id] = .notLoaded
            }
        }
    }

    func setDocumentInfo(_ info: DocumentInfo) {
        self.documentInfo = info
    }
}

// MARK: - Asset Importing

extension AssetManager {

    /// Import an image from an photo from the user's photo libray, chosen by the user from a `PhotosPicker`.
    ///
    /// - Parameter item: The `PhotosPickerItem` represengint the selected photo.
    /// - Throws:
    /// - Returns: The identifier of the imported asset.
    func addAsset(fromPhotosPickerItem item: PhotosPickerItem) async throws(AssetManagerError) -> UUID {
        try await self.addAsset(kind: .image) { assetsDir in
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

    /// Imports an asset of the given `kind` from the given file `URL`.
    ///
    /// - Parameter url: The `URL` of the asset.
    /// - Throws:
    /// - Returns: The assets identifier.
    func addAsset(fromURL url: URL, kind: AssetKind) async throws(AssetManagerError) -> UUID {
        try await self.addAsset(kind: kind) { assetsDir in
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

    func addAsset(
        nodeGeneratedImage image: CIImage,
        portLocation: OutputPortLocation,
    ) -> UUID {
        let id = self.nodeAssetIdMap[portLocation, default: UUID()]

        if self.assets[id] != nil {
            self.removeAsset(id)
        }

        self.registerAsset(
            .init(
                id: id,
                state: .loaded(.generated(portLocation)),
                added: .now,
                kind: .image
            )
        )
        self.ciImages[id] = .loaded(image)
        self.nodeAssetIdMap[portLocation] = id

        return id
    }

    /// Registers an empty asset without importing any data.
    ///
    /// - Parameter asset: The asset to be registered.
    func registerAsset(_ asset: Asset) {
        self.assets[asset.id] = asset
        switch asset.kind {
        case .image:
            self.thumbs[asset.id] = .notLoaded
            self.ciImages[asset.id] = .notLoaded
        case .lut:
            self.luts[asset.id] = .notLoaded
        }
    }

    /// A helper used by other `addAsset` methods. It takes an optional ID and a `loader` closure, which
    /// takes a `assetsDir` URL, actually does the importing of the asset, and returns the name/filename of
    /// the imported asset. This method then either returns the assets ID or throws an error.
    ///
    /// - Parameters:
    ///   - id: The optional ID of the asset that will be created/imported.
    ///   - loader: The loader closure.
    ///
    /// - Throws:
    /// - Returns: The asset ID.
    private func addAsset(
        _ id: UUID = UUID(),
        kind: AssetKind,
        loader: (_ assetsDir: URL) async throws -> String
    ) async throws(AssetManagerError) -> UUID {

        guard let documentID = self.documentInfo?.id else {
            throw .missingDocumentInfo
        }

        let id = UUID()

        self.startLoading(id, kind)

        do {
            let assetsDir: URL = .tempAssetsDirectory(forDocument: documentID)
            try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)

            let filename = try await loader(assetsDir)

            self.finishLoading(id, filename: filename)

            return id
        } catch {
            self.cancelLoading(id)
            log("\(error)", level: .error)
            if let err = error as? AssetManagerError {
                throw err
            }
            throw .assestLoadingError(.other(error))
        }
    }

    private func startLoading(_ id: UUID, _ kind: AssetKind) {
        self.removeAsset(id)
        self.registerAsset(.init(id: id, state: .loading, added: .now, kind: kind))
    }

    private func finishLoading(_ id: UUID, filename: String) {
        guard let asset = self.assets[id] else {
            fatalError("Asset \(id) not found!")
        }

        self.registerAsset(
            .init(
                id: id,
                state: .loaded(.file(filename)),
                added: asset.added,
                kind: asset.kind
            )
        )
    }

    private func cancelLoading(_ id: UUID) {
        self.removeAsset(id)
    }

    private func name(forAssetAt url: URL) -> String {
        let name = url.lastPathComponent
        let basename = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension

        let names = self.assetNames

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

    private var assetNames: [String] {
        self.assets.values.compactMap { asset in
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
    func removeAsset(_ id: UUID) -> Asset? {
        self.thumbs[id] = nil
        self.ciImages[id] = nil
        self.luts[id] = nil
        return self.assets.removeValue(forKey: id)
    }
}

// MARK: - Load Asset Resources

extension AssetManager {
    func getThumb(forAsset id: UUID) async throws(AssetManagerError) -> CGImage {
        guard let asset = self.assets[id] else {
            throw AssetManagerError.thumbnailLoadingError(.assetNotFound(id))
        }

        let value =
            switch asset.kind {
            case .image:
                try await self.getThumb(forImageAsset: id)
            case .lut:
                try await self.getThumb(forFileAsset: id)
            }
        return value
    }

    func getThumb(forFileAsset id: UUID) async throws(AssetManagerError) -> CGImage {
        guard let asset = self.assets[id] else {
            throw AssetManagerError.thumbnailLoadingError(.assetNotFound(id))
        }

        return try await self.getAssetResourceFromFile(
            id,
            getResource: { id, defaultValue in self.assetKindThumbs[asset.kind, default: defaultValue] },
            setResource: { id, res in self.assetKindThumbs[asset.kind] = res },
            load: { url in
                #if os(macOS)
                switch asset.kind {
                case .image:
                    return NSImage.init(systemSymbolName: "doc.fill", accessibilityDescription: nil)!.cgImage(
                        forProposedRect: nil,
                        context: nil,
                        hints: nil
                    )!
                case .lut:
                    var rect = CGRect(x: 0, y: 0, width: 128, height: 128)
                    return NSImage(named: "file-icon-lut")!.cgImage(
                        forProposedRect: &rect,
                        context: nil,
                        hints: [.interpolation: NSImageInterpolation.high]
                    )!
                }
                #else
                switch asset.kind {
                case .image:
                    return UIImage(systemName: "doc.fill")!.cgImage!
                case .lut:
                    return UIImage(named: "file-icon-lut")!.cgImage!
                }
                #endif
            }
        )
    }

    func getThumb(forImageAsset id: UUID) async throws(AssetManagerError) -> CGImage {
        try await self.getAssetResourceFromFile(
            id,
            getResource: { id, defaultValue in self.thumbs[id, default: .notLoaded] },
            setResource: { id, res in self.thumbs[id] = res },
            load: { url in
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
                    throw AssetManagerError.thumbnailLoadingError(.cgImageSourceCreateWithURLError)
                }

                guard let thumb = CGImageSourceCreateThumbnailAtIndex(source, 0, opts) else {
                    throw AssetManagerError.thumbnailLoadingError(.cgImageSourceCreateThumbnailError)
                }

                return thumb
            }
        )
    }

    func getCubeLut(forAsset id: UUID) async throws(AssetManagerError) -> CubeLut {
        try await self.getAssetResourceFromFile(
            id,
            isValidAssetKind: { $0 == .lut },
            getResource: { id, defaultValue in self.luts[id, default: defaultValue] },
            setResource: { id, res in self.luts[id] = res },
            load: { url in
                let data = try Data(contentsOf: url)
                guard let source = String(data: data, encoding: .utf8) else {
                    throw AssetManagerError.resouceLoadingError(.cubeLutStringDecode)
                }
                let lut = try CubeLut(source: source)
                return lut
            }
        )
    }

    func getCIImage(forAsset id: UUID) async throws(AssetManagerError) -> CIImage {
        if case let .loaded(image) = self.ciImages[id] {
            image
        } else {
            try await self.getAssetResourceFromFile(
                id,
                isValidAssetKind: { $0 == .image },
                getResource: { id, defaultValue in self.ciImages[id, default: defaultValue] },
                setResource: { id, res in self.ciImages[id] = res },
                load: { url in
                    let options: [CIImageOption: Any] = [
                        .applyOrientationProperty: true
                            // .nearestSampling: true,
                            // .expandToHDR: true,
                    ]
                    guard let ciImage = CIImage(contentsOf: url, options: options) else {
                        throw AssetManagerError.resouceLoadingError(.ciImageInitError)
                    }
                    return ciImage
                }
            )
        }
    }

    private func getAssetResourceFromFile<ResourceType: Sendable>(
        _ id: UUID,
        isValidAssetKind: ((AssetKind) -> Bool)? = nil,
        getResource: (UUID, _ default: Resource<ResourceType, AssetManagerError>) -> Resource<
            ResourceType, AssetManagerError
        >,
        setResource: (UUID, Resource<ResourceType, AssetManagerError>) -> (),
        load: @escaping @Sendable (_ fileURL: URL) async throws -> ResourceType,
    ) async throws(AssetManagerError) -> ResourceType {
        guard let asset = self.assets[id] else {
            throw AssetManagerError.thumbnailLoadingError(.assetNotFound(id))
        }

        if let isValidAssetKind, !isValidAssetKind(asset.kind) {
            throw AssetManagerError.invalidAssetKind(asset.kind, expected: nil)
        }

        guard let filename = asset.filename else {
            throw .resouceLoadingError(.isNotFileAsset)
        }

        let res = getResource(id, .notLoaded)

        var task: Task<ResourceType, any Error>? = nil

        switch res {
        case .failed(let err):
            throw err
        case .loaded(let image):
            return image
        case .loading(let t):
            task = t
        case .notLoaded:
            let url = try self.assetURL(filename: filename)
            task = Task {
                try await Task.detached { try await load(url) }.value
            }
            setResource(id, .loading(task!))
        }

        do {
            let value = try await task!.value
            setResource(id, .loaded(value))
            return value
        } catch {
            if let err = error as? AssetManagerError {
                setResource(id, .failed(err))
                throw err
            } else {
                setResource(id, .failed(.resouceLoadingError(.other(error))))
                throw .resouceLoadingError(.other(error))
            }
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

    private func assetURL(filename: String) throws(AssetManagerError) -> URL {
        let fm = FileManager.default

        let maybeDocumentImageURL = self.documentAssetURL(filename: filename)

        let tempAssetURL = self.tempAssetURL(filename: filename)!

        let assetURL =
            if let documentImageURL = maybeDocumentImageURL, fm.fileExists(atPath: documentImageURL.path) {
                documentImageURL
            } else if fm.fileExists(atPath: tempAssetURL.path) {
                tempAssetURL
            } else {
                throw AssetManagerError.thumbnailLoadingError(
                    .fileNotFound(document: maybeDocumentImageURL, temp: tempAssetURL)
                )
            }

        return assetURL
    }
}

extension AssetManager: BackendAssetProvider {
    func backendAssetProviderGetLut(_ id: UUID) async throws(Backend.BackendAssetProviderError) -> CubeLutKit.CubeLut {
        do {
            return try await self.getCubeLut(forAsset: id)
        } catch {
            log("\(error)", level: .error)
            throw .other(error)
        }
    }

    func backendAssetProviderGetImage(
        _ id: Values.ImageIdentifier
    ) async throws(Backend.BackendAssetProviderError) -> CIImage {
        let uuid =
            switch id {
            case .asset(let id): id
            case .nodeOutput(let node, let port):
                self.nodeAssetIdMap[.init(node: node, index: port), default: .init()]
            }

        do {
            return try await self.getCIImage(forAsset: uuid)
        } catch {
            log("\(error)", level: .error)
            throw .other(error)
        }
    }

    func backendAssetProviderAddImage(
        _ image: CIImage,
        id: Values.ImageIdentifier
    ) async throws(Backend.BackendAssetProviderError) {
        guard case let .nodeOutput(node, port) = id else {
            log("invalidID: \(id, default: "nil")", level: .error)
            throw .tyingToAddImageWithAssetIdentifier(id)
        }

        let portLocation = OutputPortLocation(node: node, index: port)

        _ = self.addAsset(nodeGeneratedImage: image, portLocation: portLocation)
    }
}
