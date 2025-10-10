import Logging
import Photos
import SwiftUI

@Observable
@MainActor
final class AssetStore {

    private(set) var images: [UUID: ImageAsset] = [:]

    var fileAssets: [ImageAsset] {
        self.images.values.filter { asset in
            asset.source.isFile
        }
    }

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
    func addImage(fromURL url: URL, undoManager um: UndoManager? = nil) async throws -> UUID {
        let id = try await self.assetManager.addImageAsset(fromURL: url)
        log("Registering undo!! \(id), is undo nil? \(um == nil)")
        um?.beginUndoGrouping()
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.removeImage(id, undoManager: um)
            }
        )
        um?.endUndoGrouping()
        return id
    }

    @discardableResult
    func addImageAsset(fromPHAsset asset: PHAsset, undoManager um: UndoManager? = nil) async throws -> UUID {
        let id = try await self.assetManager.addImageAsset(fromPHAsset: asset)
        um?.beginUndoGrouping()
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.removeImage(id, undoManager: um)
            }
        )
        um?.endUndoGrouping()
        return id
    }

    private func registerImage(_ asset: ImageAsset, undoManager um: UndoManager? = nil) {
        Task {
            await self.assetManager.registerImage(asset)
        }

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                self.removeImage(asset.id, undoManager: um)
            }
        )
    }

    func removeImage(_ id: UUID, undoManager um: UndoManager? = nil) {
        guard let asset = self.images[id] else { return }
        Task {
            await self.assetManager.removeImage(id)
        }
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.registerImage(asset, undoManager: um)
            }
        )
    }

    func getThumb(forImageAsset id: UUID) async throws -> CGImage {
        try await self.assetManager.getThumb(forImageAsset: id)
    }

    private func onAssetManagerEvent(_ event: AssetManager.Event) async {
        switch event {
        case .imageAssetsDidChange:
            self.images = await self.assetManager.imageAssets
        }
    }
}

extension AssetStore: Storable {
    convenience init(_ data: StorableData) {
        self.init()
        Task {
            await self.assetManager.restore(data.images)
        }
    }

    func restore(_ snapshot: StorableData) {
        self.images = [:]
        Task {
            await self.assetManager.restore(snapshot.images)
        }
    }

    func snapshot() -> StorableData {
        .init(images: self.images)
    }

    struct StorableData: Sendable, Codable {
        var images: [UUID: ImageAsset] = [:]
    }
}
