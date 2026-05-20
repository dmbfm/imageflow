import Backend
import Helpers
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
            // logger.info("assets:didSet:\("\(self.assets)")")
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

    var documentInfo: DocumentInfo? = nil

    public func setDocumentInfo(_ info: DocumentInfo) {
        self.documentInfo = info
        Task {
            await self._assetManager.setDocumentInfo(info)
        }
    }

    public var documentID: UUID? {
        self.documentInfo?.id
    }

    public func titleForAsset(id: AssetIdentifier) -> String? {
        if case let .asset(id) = id {
            self.filenameCache.get(id: id) ?? self.assets[id]?.originalFilename
        } else {
            nil
        }
    }

    public func registerAsset(asset: Asset) {
        Task {
            await self._assetManager.register(asset: asset)
        }
    }

    @discardableResult
    public func importAsset(
        imageItemProvider provider: NSItemProvider,
    ) async throws(AssetStoreServiceError) -> UUID {

        let id = UUID()

        let asset = Asset(id: id, kind: .image, timestamp: .now, state: .loading(originalFilename: nil))
        await self._assetManager.register(asset: asset)
        let assetsURL = try await self._assetManager.ensureAssetsDir()

        do {
            try await withCheckedThrowingContinuation {
                @MainActor (continuation: CheckedContinuation<Void, any Error>) in
                _ = provider.loadFileRepresentation(
                    for: .image,
                    completionHandler: { url, _, error in
                        if let url {
                            do {
                                let originalFilename: String = url.lastPathComponent
                                Task { @MainActor in
                                    await self._assetManager.register(
                                        asset: asset.with(\.state, .loading(originalFilename: originalFilename))
                                    )
                                }
                                let filename = assetFilename(forOriginalURL: url, id: asset.id)
                                let dest = assetsURL.appending(path: filename)
                                try FileManager.default.copyItem(at: url, to: dest)
                                Task { @MainActor in
                                    await self._assetManager.register(
                                        asset: asset.with(
                                            \.state,
                                            .loaded(filename: filename, originalFilename: originalFilename)
                                        )
                                    )
                                }
                            } catch {
                                continuation.resume(throwing: error)
                            }
                        } else if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(throwing: AssetStoreServiceError.message("Unknown error"))
                        }
                    }
                )
            }
        } catch {
            await self._assetManager.remove(asset: id)
            throw .from(error)
        }

        return id
    }

    @discardableResult
    public func importAsset(
        id: UUID? = UUID(),
        kind: AssetKind,
        originalFilename: String? = nil,
        importFunc: @Sendable (_ assetsDir: URL, _ id: UUID) async throws -> AssetStoreImportFuncResult
    ) async throws(AssetStoreServiceError) -> UUID {
        try await self._assetManager.importAsset(
            id: id ?? .init(),
            kind: kind,
            originalFilename: originalFilename,
            importFunc: importFunc
        )
    }

    @discardableResult
    public func addAsset(
        fromURL url: URL,
        kind: AssetKind,
        undoManager um: UndoManager? = nil
    ) async throws(AssetStoreServiceError) -> UUID {
        let id = try await self._assetManager.importAsset(fromURL: url, kind: kind)
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
    ) async throws(AssetStoreServiceError) -> UUID {
        let id = try await self._assetManager.importAsset(data: data, filename: filename, kind: kind)
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

    public func getThumb(forAsset id: UUID) async throws(AssetStoreServiceError) -> CGImage? {
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

    public func getGeneratedResource(
        ciImageAt port: OutputPortLocation
    ) async throws(AssetStoreServiceError) -> GeneratedResource<CIImage> {
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
        self.assets = snapshot.assets
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
