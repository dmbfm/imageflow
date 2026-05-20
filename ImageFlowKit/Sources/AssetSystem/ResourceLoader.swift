import CoreImage
import Foundation
import SharedModels
import Values

#if os(macOS)
import AppKit
#endif

protocol ResourceLoader: Sendable {
    associatedtype R: ResourceType
    @concurrent
    static func load(store: ResourceLoaderAssetStoreProxy, id: R.Key) async throws -> R.StoredType
}

struct CIImageLoader: ResourceLoader {

    enum Errors: Error {
        case cantLoadGeneratedResource
        case ciImageCreateError
    }

    @concurrent
    static func load(store: ResourceLoaderAssetStoreProxy, id: AssetIdentifier) async throws -> CIImage {
        guard case let .asset(id) = id else {
            throw Errors.cantLoadGeneratedResource
        }

        let url = try await store.url(forAsset: id)

        let options: [CIImageOption: Any] = [
            .applyOrientationProperty: true
                // .nearestSampling: true,
                // .expandToHDR: true,
        ]
        guard let ciImage = CIImage(contentsOf: url, options: options) else {
            throw Errors.ciImageCreateError
        }

        return ciImage
    }

    typealias R = CIImageResourceType
}

struct ThumbLoader: ResourceLoader {

    typealias R = CGImageThumbnailResourceType

    enum Errors: Error {
        case thumbCGImageSourceCreateWithURLError
        case thumbCGImageSourceCreateThumbnailError
    }

    @concurrent
    static func load(store: ResourceLoaderAssetStoreProxy, id: ThumbnailResourceKey) async throws -> CGImage {
        switch id {
        case .asset(let id):
            try await Self.load(store: store, assetID: id)
        case .kind(let kind):
            try await Self.load(store: store, assetKind: kind)
        }
    }

    @concurrent
    static func load(store: ResourceLoaderAssetStoreProxy, assetKind kind: AssetKind) async throws -> CGImage {
        #if os(macOS)
        switch kind {
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

    @concurrent
    static func load(store: ResourceLoaderAssetStoreProxy, assetID id: UUID) async throws -> CGImage {

        let url = try await store.url(forAsset: id)

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
            logger.error("error: thumbCGImageSourceCreateWithURLError")
            throw Errors.thumbCGImageSourceCreateWithURLError
        }

        let thumbTask = Task.detached {
            CGImageSourceCreateThumbnailAtIndex(source, 0, opts)
        }

        guard let thumb = await thumbTask.value else {
            logger.error("error: thumbCGImageSourceCreateThumbnailError")
            throw Errors.thumbCGImageSourceCreateThumbnailError
        }

        return thumb
    }
}

@MainActor
struct ResourceLoaderAssetStoreProxy {
    private weak var store: AssetStore?

    init(_ store: AssetStore) {
        self.store = store
    }

    func withStore<T>(_ perform: (AssetStore) throws(AssetSystemError) -> T) throws(AssetSystemError) -> T {
        guard let store = self.store else {
            throw .assetStoreReferenceNil
        }

        return try perform(store)
    }

    func getAsset(id: UUID) throws(AssetSystemError) -> Asset {
        try self.withStore { (store) throws(AssetSystemError) in
            guard let asset = store.assets[id] else {
                throw .assetNotFound
            }

            return asset
        }
    }

    func url(forAsset id: UUID) throws(AssetSystemError) -> URL {
        try self.withStore { (store) throws(AssetSystemError) in
            guard let asset = store.assets[id] else {
                throw .assetNotFound
            }

            return try store.pathManager.url(forReadingAsset: asset)
        }
    }
}
