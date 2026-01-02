import Logging
import Photos
import PhotosUI
import SwiftUI
import Values

@MainActor
protocol AssetStoreService: AnyObject {
    func getGeneratedResource(ciImageAt port: OutputPortLocation) async throws -> GeneratedResource<CIImage>
    func hasGeneratedResource(ciImageAt port: OutputPortLocation) async -> Bool
    var modifiedGeneratedAssetStream: AsyncStream<OutputPortLocation> { get }
    init()
}

@Observable
@MainActor
final class AssetStore: AssetStoreService {

    private(set) var assets: [UUID: Asset] = [:]

    @ObservationIgnored
    var thumbCache: [UUID: CGImage] = [:]

    let assetManager: AssetManager = .init()

    init() {
        self.assetManager.emitter.on { [weak self] event in
            Task { @MainActor in
                await self?.onAssetManagerEvent(event)
            }
        }
    }

    func setDocumentInfo(_ info: DocumentInfo) {
        Task {
            await self.assetManager.setDocumentInfo(info)
        }
    }

    @discardableResult
    nonisolated func addAssets(
        fromPhotosPickerItems items: [PhotosPickerItem],
        undoManager um: UndoManager? = nil
    ) async throws(AssetManagerError) -> [UUID] {
        do {
            return try await withThrowingTaskGroup(of: UUID.self, returning: [UUID].self) { group in
                for item in items {
                    group.addTask {
                        try await self.addAsset(
                            fromPhotosPickerItem: item,
                            undoManager: um
                        )
                    }
                }

                return try await group.reduce(
                    into: [UUID](),
                    { acc, id in
                        acc.append(id)
                    }
                )
            }
        } catch {
            throw .from(error)
        }
    }

    @discardableResult
    func addAsset(
        fromPhotosPickerItem item: PhotosPickerItem,
        undoManager um: UndoManager? = nil
    ) async throws(AssetManagerError) -> UUID {
        let id = try await self.assetManager.importImageAsset(fromPhotosPickerItem: item)
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.removeAsset(id, undoManager: um)
            }
        )
        return id
    }

    @discardableResult
    func addAsset(
        fromURL url: URL,
        kind: AssetKind,
        undoManager um: UndoManager? = nil
    ) async throws(AssetManagerError) -> UUID {
        let id = try await self.assetManager.importAsset(fromURL: url, kind: kind)
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.removeAsset(id, undoManager: um)
            }
        )
        return id
    }

    private func registerAsset(_ asset: Asset, undoManager um: UndoManager? = nil) {
        Task {
            await self.assetManager.register(asset: asset)
        }

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                self.removeAsset(asset.id, undoManager: um)
            }
        )
    }

    func removeAsset(_ id: UUID, undoManager um: UndoManager? = nil) {
        guard let asset = self.assets[id] else { return }
        guard asset.kind == .image else { return }
        Task {
            await self.assetManager.remove(asset: id)
        }
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.registerAsset(asset, undoManager: um)
            }
        )
    }

    func getThumb(forAsset id: UUID) async throws -> CGImage? {
        // NOTE: Returning the thumb that is cached in the manager has a
        // performance penalty (I think it needs to copy the CGImage data
        // or some mutex/locking issue). So we keep an additional cache
        // here so we can return the thumbnail quickly.
        if let thumb = self.thumbCache[id] {
            return thumb
        } else {
            let result = try await self.assetManager.getAssetResource(thumbFor: id)
            self.thumbCache[id] = result
            return result
        }
    }

    func getGeneratedResource(ciImageAt port: OutputPortLocation) async throws -> GeneratedResource<CIImage> {
        try await self.assetManager.getGeneratedResource(ciImageAt: port)
    }

    func hasGeneratedResource(ciImageAt port: OutputPortLocation) async -> Bool {
        await self.assetManager.hasGeneratedResource(ciImageAt: port)
    }

    private func onAssetManagerEvent(_ event: AssetManager.Event) async {
        switch event {
        case .assetsDidChange:
            self.assets = await self.assetManager.assets
        case .modifiedGeneratedAsset(let location):
            self.asyncStreamAdapterCallback?(location)
        }
    }

    var modifiedGeneratedAssetStream: AsyncStream<OutputPortLocation> {
        .init { continuation in
            self.asyncStreamAdapterCallback = { loc in
                continuation.yield(loc)
            }
        }
    }

    private var asyncStreamAdapterCallback: ((OutputPortLocation) -> ())?
}

extension AssetStore: Storable {
    convenience init(_ data: StorableData) {
        self.init()
        Task {
            await self.assetManager.restore(assets: data.assets)
        }
    }

    func restore(_ snapshot: StorableData) {
        self.assets = [:]
        Task {
            await self.assetManager.restore(assets: snapshot.assets)
        }
    }

    func snapshot() -> StorableData {
        .init(assets: self.assets)
    }

    struct StorableData: Sendable, Codable {
        var assets: [UUID: Asset] = [:]
    }
}
