import Backend
import CoreImage
import CubeLutKit
import Foundation
import Helpers
import Logging
import Photos
import PhotosUI
import SharedModels
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

struct AssetResources {
    var luts: ResourceCollection<CubeLut> = .init()
    var thumbs: ResourceCollection<CGImage> = .init()
    var ciImages: ResourceCollection<CIImage> = .init()
    var assetKindThumbs: [AssetKind: Resource<CGImage, AssetManagerError>] = [:]

    mutating func clear() {
        self = .init()
    }
}

struct GeneratedResources {
    var ciImages: [OutputPortLocation: GeneratedResource<CIImage>] = [:]

    mutating func removeCIImages(forNode node: UUID) {
        self.ciImages = self.ciImages.filter { $0.key.node != node }
    }

    mutating func clear() {
        self = .init()
    }
}

actor AssetManager {
    // MARK: - Exposed Properties

    private(set) var assets: [UUID: Asset] = [:] { didSet { self.assetsDidChange(oldValue) } }
    @MainActor var onEvent: ((Event) -> ())?

    // MARK: - Exposed Types

    enum Event {
        case assetsDidChange
        case modifiedGeneratedAsset(OutputPortLocation)
    }

    // MARK: - Private Properties

    private(set) var assetResources: AssetResources = .init()
    private(set) var generatedResources: GeneratedResources = .init()
    private(set) var documentInfo: DocumentInfo?

    // MARK: - Private Types

    private typealias Res<T> = Resource<T, AssetManagerError>

    // MARK: - Exposed Methods

    func setDocumentInfo(_ value: DocumentInfo) {
        self.documentInfo = value
    }

    func assets(ofKind kind: AssetKind) -> [Asset] {
        self.assets.values.filter({ $0.kind == kind })
    }

    func clear() {
        self.assets.removeAll()
        self.assetResources.clear()
        self.generatedResources.clear()
    }

    func restore(assets: [UUID: Asset]) {
        self.clear()
        for (_, asset) in assets {
            self.register(asset: asset)
        }
    }

    @discardableResult
    func remove(asset id: UUID) -> Asset? {
        if let asset = self.assets[id] {
            self.assets.removeValue(forKey: id)
            switch asset.kind {
            case .image:
                self.assetResources.ciImages[id] = nil
                self.assetResources.thumbs[id] = nil
            case .lut:
                self.assetResources.luts[id] = nil
            }

            return asset
        }

        return nil
    }

    func remove(generatedAssetsForNode node: UUID) {
        self.generatedResources.removeCIImages(forNode: node)
    }

    func importImageAsset(fromPhotosPickerItem item: PhotosPickerItem) async throws(AssetManagerError) -> UUID {
        try await self.importAsset(kind: .image) { assetsDir, id in
            guard let identifier = item.itemIdentifier else {
                throw AssetManagerError.importAsset(.photosMissingIdentifier)
            }

            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw AssetManagerError.importAsset(.photosDataIsNil)
            }

            let fetchAssetResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)

            guard let asset = fetchAssetResult.firstObject else {
                throw AssetManagerError.importAsset(.photosMissingIdentifier)
            }

            guard let resource = PHAssetResource.assetResources(for: asset).first else {
                throw AssetManagerError.importAsset(.photosMissingPHAssetResource)
            }

            let filename = resource.originalFilename
            let assetFilename = self.name(forAssetWithFilename: filename, id: id)

            try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)
            let assetURL = assetsDir.appending(path: assetFilename)

            try data.write(to: assetURL)

            return .init(filename: assetFilename, originalFilename: filename)
        }
    }

    func importAsset(fromURL url: URL, kind: AssetKind) async throws(AssetManagerError) -> UUID {
        try await self.importAsset(kind: kind) { assetsDir, id in
            guard url.startAccessingSecurityScopedResource() else {
                throw AssetManagerError.importAsset(.URLAccessError)
            }
            defer { url.stopAccessingSecurityScopedResource() }

            let assetFilename = self.name(forAssetAt: url, id: id)
            let assetURL = assetsDir.appending(path: assetFilename)

            try FileManager.default.copyItem(at: url, to: assetURL)

            return .init(filename: assetFilename, originalFilename: url.lastPathComponent)
        }
    }

    func addGeneratedResource<T>(id: OutputPortLocation, resource: T) throws(AssetManagerError) {
        if let res = resource as? CIImage? {
            if let res {
                self.generatedResources.ciImages[id] = .init(id: id, timestamp: .now, res: res)
            } else {
                self.generatedResources.ciImages[id] = nil
            }
            self.emit(.modifiedGeneratedAsset(id))
        } else {
            throw .addGeneratedResource(.invalidResourceType)
        }
    }

    func getGeneratedResource(
        ciImageAt port: OutputPortLocation
    ) async throws(AssetManagerError) -> GeneratedResource<CIImage> {
        if let res = self.generatedResources.ciImages[port] {
            return res
        } else {
            throw .getGeneratedResource(.resourceNotFound)
        }
    }

    func hasGeneratedResource(
        ciImageAt port: OutputPortLocation
    ) -> Bool {
        self.generatedResources.ciImages[port] != nil
    }

    func getGeneratedResource(
        thumbAt port: OutputPortLocation
    ) async throws(AssetManagerError) -> GeneratedResource<CGImage> {
        fatalError("TODO")
    }

    func getGeneratedResource(
        lutAt port: OutputPortLocation
    ) async throws(AssetManagerError) -> GeneratedResource<CubeLut> {
        fatalError("Not supported")
    }

    func getAssetResource(thumbFor id: UUID) async throws(AssetManagerError) -> CGImage {
        guard let asset = self.assets[id] else {
            throw .getAssetResource(.assetNotFound)
        }

        switch asset.kind {
        case .image:
            return try await self.getAssetResource(
                forAssetID: id,
                loader: .init(
                    getResource: { id in self.assetResources.thumbs[id] },
                    setResource: { id, res in self.assetResources.thumbs[id] = res },
                    loadFromFile: { url in try await generateThumb(fromURL: url) }
                )
            )
        default:
            return try await self.getAssetResource(
                forAssetID: id,
                loader: .init(
                    getResource: { _ in self.assetResources.assetKindThumbs[asset.kind] },
                    setResource: { _, res in self.assetResources.assetKindThumbs[asset.kind] = res },
                    loadFromFile: { _ in try await generateNonImageFileThumb(fromAsset: asset) }
                )
            )
        }
    }

    func getAssetResource(ciImageFor id: UUID) async throws(AssetManagerError) -> CIImage {
        try await self.getAssetResource(
            forAssetID: id,
            loader: .init(
                getResource: { id in self.assetResources.ciImages[id] },
                setResource: { id, res in self.assetResources.ciImages[id] = res },
                loadFromFile: { url in
                    let options: [CIImageOption: Any] = [
                        .applyOrientationProperty: true
                            // .nearestSampling: true,
                            // .expandToHDR: true,
                    ]
                    guard let ciImage = CIImage(contentsOf: url, options: options) else {
                        throw AssetManagerError.getAssetResource(.ciImageInitError)
                    }
                    return ciImage
                }
            )
        )
    }

    func getAssetResource(lutFor id: UUID) async throws(AssetManagerError) -> CubeLut {
        fatalError("TODO")
    }

    // MARK: - Private Methods

    private func emit(_ event: Event) {
        Task { @MainActor in
            self.onEvent?(event)
        }
    }

    private func assetsDidChange(_ oldValue: [UUID: Asset]) {
        if oldValue != self.assets {
            self.emit(.assetsDidChange)
        }
    }

    func register(asset: Asset) {
        self.assets[asset.id] = asset
        switch asset.kind {
        case .image:
            self.assetResources.ciImages[asset.id] = .notLoaded
            self.assetResources.thumbs[asset.id] = .notLoaded
        case .lut:
            self.assetResources.luts[asset.id] = .notLoaded
        }
    }

    struct ImportFuncResult {
        var filename: String
        var originalFilename: String
    }

    private func importAsset(
        id: UUID = UUID(),
        kind: AssetKind,
        importFunc: (_ assetsDir: URL, _ id: UUID) async throws -> ImportFuncResult
    ) async throws(AssetManagerError) -> UUID {
        guard let documentID = self.documentInfo?.id else {
            throw .importAsset(.missingDocumentInfo)
        }

        self.register(asset: .init(id: id, kind: kind, timestamp: .now, state: .loading))

        do {
            let assetsDir: URL = .tempAssetsDirectory(forDocument: documentID)

            try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)

            let result = try await importFunc(assetsDir, id)

            self.register(
                asset: .init(
                    id: id,
                    kind: kind,
                    timestamp: .now,
                    state: .loaded(filename: result.filename, originalFilename: result.originalFilename)
                )
            )
        } catch {
            throw .from(error)
        }

        return id
    }

    private func name(forAssetAt url: URL, id: UUID) -> String {
        // let name = url.lastPathComponent
        // let basename = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        let storedName =
            if ext.isEmpty {
                "\(id.uuidString)"
            } else {
                "\(id.uuidString).\(ext)"
            }

        return storedName
    }

    private func name(forAssetWithFilename name: String, id: UUID) -> String {
        self.name(forAssetAt: .init(filePath: name), id: id)
    }

    private func documentAssetURL(filename: String) -> URL? {
        self.documentInfo?.url?.appending(path: "Assets").appending(path: filename)
    }

    private func tempAssetURL(filename: String) -> URL? {
        if let id = self.documentInfo?.id {
            .tempAssetURL(forDocument: id, filename: filename)
        } else {
            nil
        }
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
                throw .getAssetResource(.resourceNotFound)
            }

        return assetURL
    }

    private struct AssetResourceLoader<T> {
        var getResource: (_ id: UUID) -> Res<T>?
        var setResource: (_ id: UUID, _ res: Res<T>?) -> ()
        var loadFromFile: @Sendable (_ url: URL) async throws -> T
    }

    private func getAssetResource<T>(
        forAssetID id: UUID,
        loader: AssetResourceLoader<T>
    ) async throws(AssetManagerError) -> T where T: Sendable {
        guard let asset = self.assets[id] else {
            throw .getAssetResource(.assetNotFound)
        }

        return try await self.getAssetResource(forAsset: asset, loader: loader)
    }

    private func getAssetResource<T>(
        forAsset asset: Asset,
        loader: AssetResourceLoader<T>
    ) async throws(AssetManagerError) -> T where T: Sendable {
        guard let res = loader.getResource(asset.id) else {
            throw .getAssetResource(.resourceNotFound)
        }

        guard case let .loaded(filename: filename, _) = asset.state else {
            throw .getAssetResource(.assetNotLoaded)
        }

        var task: Task<T, any Error>? = nil
        switch res {
        case .loaded(let value):
            return value
        case .failed(let err):
            throw err
        case .loading(let t):
            task = t
        case .notLoaded:
            task = Task {
                let loadFromFile = loader.loadFromFile
                return try await Task.detached {
                    try await loadFromFile(self.assetURL(filename: filename))
                }.value
            }
        }

        do {
            return try await task!.value
        } catch {
            throw .from(error)
        }
    }
}

public enum AssetManagerError: LocalizedError, Sendable {
    case other(any Error)
    case addGeneratedResource(AddGeneratedResource)
    case getGeneratedResource(GetGeneratedResource)
    case getAssetResource(GetAssetResource)
    case importAsset(ImportAsset)

    public enum AddGeneratedResource: Error {
        case invalidResourceType
    }

    public enum ImportAsset: Error {
        case missingDocumentInfo
        case photosMissingIdentifier
        case photosDataIsNil
        case photosMissingPHAssetResource
        case URLAccessError
    }

    public enum GetGeneratedResource: Error {
        case resourceNotFound
    }

    public enum GetAssetResource: Error {
        case resourceNotFound
        case assetNotLoaded
        case assetNotFound
        case thumbCGImageSourceCreateWithURLError
        case thumbCGImageSourceCreateThumbnailError
        case ciImageInitError
    }

    static func from(_ error: any Error) -> AssetManagerError {
        if let err = error as? AssetManagerError {
            err
        } else {
            .other(error)
        }
    }
}

extension AssetManager: BackendAssetProvider {
    func backendAssetProviderGetLut(
        _ id: AssetIdentifier
    ) async throws -> CubeLutKit.CubeLut {
        switch id {
        case .nodeOutput(let node, let index):
            return try await self.getGeneratedResource(lutAt: .init(node: node, index: index)).res
        case .asset(let id):
            return try await self.getAssetResource(lutFor: id)
        }
    }

    func backendAssetProviderGetImage(
        _ id: AssetIdentifier
    ) async throws -> CIImage {
        switch id {
        case .nodeOutput(let node, let index):
            return try await self.getGeneratedResource(ciImageAt: .init(node: node, index: index)).res
        case .asset(let id):
            return try await self.getAssetResource(ciImageFor: id)
        }
    }

    func backendAssetProviderAddImage(
        _ image: CIImage?,
        node: UUID,
        port: Int
    ) async throws {
        try self.addGeneratedResource(id: .init(node: node, index: port), resource: image)
    }
}

func generateNonImageFileThumb(fromAsset asset: Asset) async throws -> CGImage {
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

func generateThumb(fromURL url: URL) async throws -> CGImage {
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
        log("error: thumbCGImageSourceCreateWithURLError", level: .error)
        throw AssetManagerError.getAssetResource(.thumbCGImageSourceCreateWithURLError)
    }

    let thumbTask = Task.detached {
        CGImageSourceCreateThumbnailAtIndex(source, 0, opts)
    }

    guard let thumb = await thumbTask.value else {
        log("error: thumbCGImageSourceCreateThumbnailError", level: .error)
        throw AssetManagerError.getAssetResource(.thumbCGImageSourceCreateThumbnailError)
    }

    return thumb
}
