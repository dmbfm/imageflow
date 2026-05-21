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

    public func registerAsset(_ asset: Asset, undoManager um: UndoManager? = nil) {
        self.assets[asset.id] = asset
        Task {
            await self.resourceManager.registerAssetResources(asset: asset)
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
        self.assets.removeValue(forKey: id)
        Task {
            await self.resourceManager.removeAssetResources(asset: asset)
        }
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.registerAsset(asset, undoManager: um)
            }
        )
    }

    public func importAsset(_ importer: AssetImporter, undoManager um: UndoManager? = nil) async throws -> UUID {
        try self.pathManager.ensureAssetsDir()
        let id = try await importer.doImport(.init(self, self.pathManager))
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.removeAsset(id, undoManager: um)
            }
        )
        return id
    }

    public func importAsset(
        fromData data: Data,
        filename: String,
        kind: AssetKind,
        undoManager um: UndoManager? = nil
    ) async throws -> UUID {
        try await self.importAsset(DataImporter(filename: filename, kind: kind, data: data), undoManager: um)
    }

    public func importAsset(
        fromURL url: URL,
        kind: AssetKind,
        undoManager um: UndoManager? = nil
    ) async throws -> UUID {
        try await self.importAsset(SimpleFileImporter(url: url, kind: kind), undoManager: um)
    }

    public func importAsset(
        imageFromItemProvider item: NSItemProvider,
        undoManager um: UndoManager? = nil
    ) async throws -> UUID {
        try await self.importAsset(ImageItemProviderImporter(item: item), undoManager: um)
    }
}

extension AssetStore: Storable {
    public struct StorableData: Sendable, Codable {
        public var assets: [UUID: Asset] = [:]

        public init(assets: [UUID: Asset] = [:]) {
            self.assets = assets
        }
    }

    public convenience init(_ data: StorableData) {
        self.init()
        for (_, asset) in data.assets {
            self.registerAsset(asset)
        }
    }

    public func restore(_ snapshot: StorableData) {
        Task {
            await self.resourceManager.clear()
            for (_, asset) in snapshot.assets {
                self.registerAsset(asset)
            }
        }
    }

    public func snapshot() -> StorableData {
        .init(assets: self.assets)
    }
}
