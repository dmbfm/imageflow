import Backend
import Combine
import CoreImage
import CubeLutKit
import Foundation
import SharedModels
import Values

public final actor ResourceManager {
    var storage: ResourceStorage = .init()
    weak var store: AssetStore?

    @MainActor
    var publisher: PassthroughSubject<AssetSystemEvent.Resource, Never> = .init()

    @MainActor
    var thumbCache: [ThumbnailResourceKey: CGImage] = [:]

    public init(_ store: AssetStore) {
        self.store = store
    }

    public func clear() {
        self.storage.clear()
    }

    public func hasResource(cIImageWithId id: AssetIdentifier) -> Bool {
        self.storage.images[id] != nil
    }

    public func hasResource(cubeLutWithId id: AssetIdentifier) -> Bool {
        self.storage.luts[id] != nil
    }

    public func fetch(ciImageWithid id: AssetIdentifier) async throws(AssetSystemError) -> CIImage {
        try await self.fetch(loaderType: CIImageLoader.self, id: id)
    }

    @MainActor
    public func fetch(cgImageThumb id: ThumbnailResourceKey) async throws(AssetSystemError) -> CGImage {
        if let image = self.thumbCache[id] {
            return image
        } else {
            let image = try await self.fetch(loaderType: ThumbLoader.self, id: id)
            self.thumbCache[id] = image
            return image
        }
    }

    public func registerAssetResources(asset: Asset) {
        switch asset.kind {
        case .image:
            self.storage.images[.asset(asset.id)] = .notLoaded
            self.storage.thumbnails[asset.id] = .notLoaded
        case .lut:
            self.storage.luts[.asset(asset.id)] = .notLoaded
        }
    }

    public func removeAssetResources(asset: Asset) {
        switch asset.kind {
        case .image:
            self.storage.images.remove(.asset(asset.id))
            self.storage.thumbnails.remove(asset.id)
        case .lut:
            self.storage.luts.remove(.asset(asset.id))
        }
    }

    public func remove(generatedAssetsForNode node: UUID) {
        self.storage.images.remove(where: {
            switch $0 {
            case .asset(_): false
            case .nodeOutput(let id, _): id == node
            }
        })
    }

    public func addResource(image: CIImage?, for id: AssetIdentifier) {
        if let image {
            self.storage.images[id] = .loaded(image)
            self.emit(.didAddImage(id))
        } else {
            switch id {
            case .asset(_):
                self.storage.images[id] = .notLoaded
            case .nodeOutput(_, _):
                self.storage.images[id] = nil
                self.emit(.didRemoveImage(id))
            }
        }
    }

    private func fetch<Loader: ResourceLoader>(
        loaderType: Loader.Type,
        id: Loader.R.Key
    ) async throws(AssetSystemError) -> Loader.R.StoredType {
        guard let res = Loader.R.getResource(storage: self.storage, id: id) else {
            throw .fetch(.resourceNotFound)
        }

        var task: Task<Loader.R.StoredType, any Error>? = nil
        switch res {
        case .failed(let err):
            throw err
        case .loading(let t):
            task = t
        case .loaded(let loaded):
            return loaded
        case .notLoaded:
            guard let store = self.store else {
                throw .assetStoreReferenceNil
            }

            let proxy = await ResourceLoaderAssetStoreProxy(store)

            let t: Task<Loader.R.StoredType, any Error> = Task {
                let res = try await Loader.load(store: proxy, id: id)
                Loader.R.setResource(storage: &self.storage, id: id, res: .loaded(res))
                return res
            }
            Loader.R.setResource(storage: &self.storage, id: id, res: .loading(t))
            task = t
        }

        do {
            let res = try await task!.value
            Loader.R.setResource(storage: &self.storage, id: id, res: .loaded(res))
            return res
        } catch {
            Loader.R.setResource(storage: &self.storage, id: id, res: .failed(.other(error)))
            throw .other(error)
        }
    }

    private func emit(_ event: AssetSystemEvent.Resource) {
        Task { @MainActor in
            self.publisher.send(event)
        }
    }
}

extension ResourceManager: BackendAssetProvider {
    public func backendAssetProviderGetLut(_ id: Values.AssetIdentifier) async throws -> CubeLut {
        fatalError("TODO: backendAssetProviderGetLut")
    }

    public func backendAssetProviderGetImage(_ id: Values.AssetIdentifier) async throws -> CIImage {
        try await self.fetch(ciImageWithid: id)
    }

    public func backendAssetProviderAddImage(_ image: CIImage?, node: UUID, port: Int) async throws {
        self.addResource(image: image, for: .nodeOutput(node, port))
    }
}
