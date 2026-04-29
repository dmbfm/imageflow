import Backend
import Helpers
import Logging
import Photos
import PhotosUI
import SharedModels
import SwiftUI
import Values

@Observable
@MainActor
public final class AssetStore: AssetStoreService {

    public private(set) var assets: [UUID: Asset] = [:] {
        didSet {
            logger.info("assets:didSet:\("\(self.assets)")")
            self.delegate?.assetsStore(assetsDidChange: self.assets)
            self.emitter.emit(.assetsChanged)
            self.filenameCache.refresh(assets: self.assets)
        }
    }

    public weak var delegate: AssetStoreServiceDelegate? = nil

    @ObservationIgnored
    var thumbCache: [UUID: CGImage] = [:]

    @ObservationIgnored
    var filenameCache: FilenameCache = .init()

    @ObservationIgnored
    public var emitter: EventEmitter<AssetStoreServiceEvent> = .init()

    public var assetManager: any BackendAssetProvider {
        self._assetManager
    }

    private let _assetManager = AssetManager()

    public init() {
        self._assetManager.onEvent = { [weak self] event in
            Task { @MainActor in
                await self?.onAssetManagerEvent(event)
            }
        }
    }

    public func setDocumentInfo(_ info: DocumentInfo) {
        Task {
            await self._assetManager.setDocumentInfo(info)
        }
    }

    public func titleForAsset(id: AssetIdentifier) -> String? {
        if case let .asset(id) = id {
            self.filenameCache.get(id: id) ?? self.assets[id]?.originalFilename
        } else {
            nil
        }
    }

    @discardableResult
    public nonisolated func addAssets(
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
    public func addAsset(
        fromPhotosPickerItem item: PhotosPickerItem,
        undoManager um: UndoManager? = nil
    ) async throws(AssetManagerError) -> UUID {
        let id = try await self._assetManager.importImageAsset(fromPhotosPickerItem: item)
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.removeAsset(id, undoManager: um)
            }
        )
        return id
    }

    @discardableResult
    public func addAsset(
        fromURL url: URL,
        kind: AssetKind,
        undoManager um: UndoManager? = nil
    ) async throws(AssetManagerError) -> UUID {
        let id = try await self._assetManager.importAsset(fromURL: url, kind: kind)
        log("addAsset: um == nil \(um == nil)")
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.removeAsset(id, undoManager: um)
            }
        )
        return id
    }

    public func addAsset(
        data: Data,
        filename: String,
        kind: AssetKind,
        undoManager um: UndoManager?
    ) async throws -> UUID {
        let id = try await self._assetManager.importAsset(data: data, filename: filename, kind: kind)
        log("addAsset: um == nil \(um == nil)")
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
            await self._assetManager.register(asset: asset)
        }

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.removeAsset(asset.id, undoManager: um)
            }
        )
    }

    public func removeAsset(_ id: UUID, undoManager um: UndoManager? = nil) {
        guard let asset = self.assets[id] else { return }
        guard asset.kind == .image else { return }
        Task {
            await self._assetManager.remove(asset: id)
        }
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.registerAsset(asset, undoManager: um)
            }
        )
    }

    public func remove(generatedAssetsForNode node: UUID) {
        Task {
            await self._assetManager.remove(generatedAssetsForNode: node)
        }
    }

    public func getThumb(forAsset id: UUID) async throws -> CGImage? {
        // NOTE: Returning the thumb that is cached in the manager has a
        // performance penalty (I think it needs to copy the CGImage data
        // or some mutex/locking issue). So we keep an additional cache
        // here so we can return the thumbnail quickly.
        if let thumb = self.thumbCache[id] {
            return thumb
        } else {
            let result = try await self._assetManager.getAssetResource(thumbFor: id)
            self.thumbCache[id] = result
            return result
        }
    }

    public func getGeneratedResource(ciImageAt port: OutputPortLocation) async throws -> GeneratedResource<CIImage> {
        try await self._assetManager.getGeneratedResource(ciImageAt: port)
    }

    public func hasGeneratedResource(ciImageAt port: OutputPortLocation) async -> Bool {
        await self._assetManager.hasGeneratedResource(ciImageAt: port)
    }

    private func onAssetManagerEvent(_ event: AssetManager.Event) async {
        switch event {
        case .assetsDidChange:
            self.assets = await self._assetManager.assets
        case .modifiedGeneratedAsset(let location):
            self.emitter.emit(.modifiedGeneratedAsset(location))
        }
    }
}

extension AssetStore: Storable {
    convenience public init(_ data: StorableData) {
        self.init()
        self.filenameCache = data.filenameCache ?? .init()
        Task {
            await self._assetManager.restore(assets: data.assets)
        }
    }

    public func restore(_ snapshot: StorableData) {
        self.assets = [:]
        self.filenameCache = snapshot.filenameCache ?? .init()
        Task {
            await self._assetManager.restore(assets: snapshot.assets)
        }
    }

    public func snapshot() -> StorableData {
        .init(assets: self.assets)
    }

    public struct StorableData: Sendable, Codable {
        public var assets: [UUID: Asset] = [:]
        public var filenameCache: FilenameCache? = .init()

        public init(assets: [UUID: Asset] = [:], filenameCache: FilenameCache = .init()) {
            self.assets = assets
            self.filenameCache = filenameCache
        }
    }
}
