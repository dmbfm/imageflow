import Combine
import Foundation
import SharedModels

@MainActor
public final class AssetStore {

    public internal(set) var assets: [UUID: Asset] = [:] {
        didSet {
            if self.assets != oldValue {
                self.publisher.send(.asssetsDidChange)
            }
        }
    }

    public internal(set) var resourceManager: ResourceManager!

    public var publisher: PassthroughSubject<AssetSystemEvent, Never> = .init()

    public var pathManager: PathManager {
        .init(self.documentInfo!)
    }

    private var documentInfo: DocumentInfo?
    private var cancellables: Set<AnyCancellable> = []

    public init() {
        self.resourceManager = .init(self)
        self.resourceManager.publisher.sink { [weak self] event in
            self?.publisher.send(.resource(event))
        }.store(in: &self.cancellables)
    }

    public func setDocumentInfo(_ info: DocumentInfo) {
        self.documentInfo = info
    }

    private func restoreRegisterAssets<C>(_ assets: C) async where C: Collection<Asset> {
        await withTaskGroup(of: Void.self) { group in
            for asset in assets {
                self.assets[asset.id] = asset
                group.addTask {
                    await self.resourceManager.registerAssetResources(asset: asset)
                    if asset.kind == .image {
                        _ = try? await self.resourceManager.fetch(cgImageThumb: .asset(asset.id))
                    }
                }
            }

            await group.waitForAll()
        }
    }

    public func registerAsset(_ asset: Asset, prefetchThumbs: Bool = false, undoService: UndoService? = nil) {
        self.assets[asset.id] = asset
        Task {
            await self.resourceManager.registerAssetResources(asset: asset)

            if prefetchThumbs && asset.kind == .image {
                _ = try? await self.resourceManager.fetch(cgImageThumb: .asset(asset.id))
            }
        }
        undoService?.register(
            withTarget: self,
            title: nil,
            icon: nil,
            handler: { [weak undoService] this in
                this.removeAsset(asset.id, undoService: undoService)
            }
        )
    }

    public func remove(generatedAssetsForNode node: UUID) {
        Task {
            await self.resourceManager.remove(generatedAssetsForNode: node)
        }
    }

    public func removeAsset(_ id: UUID, undoService: UndoService? = nil) {
        guard let asset = self.assets[id] else { return }
        self.assets.removeValue(forKey: id)
        Task {
            await self.resourceManager.removeAssetResources(asset: asset)
        }
        undoService?.register(
            withTarget: self,
            title: nil,
            icon: nil,
            handler: { [weak undoService] this in
                this.registerAsset(asset, undoService: undoService)
            }
        )
    }

    public func importAsset(_ importer: AssetImporter, undoService: UndoService? = nil) async throws -> UUID {
        try self.pathManager.ensureAssetsDir()
        let id = try await importer.doImport(.init(self, self.pathManager))
        undoService?.register(
            withTarget: self,
            title: nil,
            icon: nil,
            handler: { [weak undoService] this in
                this.removeAsset(id, undoService: undoService)
            }
        )
        return id
    }

    public func importAsset(
        fromData data: Data,
        filename: String,
        kind: AssetKind,
        undoService: UndoService? = nil,
    ) async throws -> UUID {
        try await self.importAsset(DataImporter(filename: filename, kind: kind, data: data), undoService: undoService)
    }

    public func importAsset(
        fromURL url: URL,
        kind: AssetKind,
        undoService: UndoService? = nil,
    ) async throws -> UUID {
        try await self.importAsset(SimpleFileImporter(url: url, kind: kind), undoService: undoService)
    }

    public func importAsset(
        imageFromItemProvider item: NSItemProvider,
        undoService: UndoService? = nil,
    ) async throws -> UUID {
        try await self.importAsset(ImageItemProviderImporter(item: item), undoService: undoService)
    }
}

extension AssetStore: Storable {

    public enum StorableData: Sendable, Codable {
        case v0(V0)

        public struct V0: Sendable, Codable {
            public var assets: [UUID: Asset] = [:]

            public init(assets: [UUID: Asset] = [:]) {
                self.assets = assets
            }
        }
    }

    public convenience init(_ data: StorableData) {
        switch data {
        case .v0(let data):
            self.init()
            for (_, asset) in data.assets {
                self.registerAsset(asset)
            }
        }
    }

    public func restore(_ snapshot: StorableData) {
        switch snapshot {
        case .v0(let snapshot):
            Task {
                await self.resourceManager.clear()
                await self.restoreRegisterAssets(snapshot.assets.values)
                self.publisher.send(.asssetsDidChange)
            }
        }
    }

    public func snapshot() -> StorableData {
        .v0(.init(assets: self.assets))
    }
}
