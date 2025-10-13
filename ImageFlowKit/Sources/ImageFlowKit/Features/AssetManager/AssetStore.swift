import Logging
import Photos
import PhotosUI
import SwiftUI

@Observable
@MainActor
final class AssetStore {

    private(set) var images: [UUID: ImageAsset] = [:]

    var fileAssets: [ImageAsset] {
        self.images.values.filter { $0.isFileAsset }
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
    nonisolated func addImageAssets(
        fromPhotosPickerItems items: [PhotosPickerItem],
        undoManager um: UndoManager? = nil
    ) async throws(AssetManagerError) -> [UUID] {
        do {
            return try await withThrowingTaskGroup(of: UUID.self, returning: [UUID].self) { group in
                for item in items {
                    group.addTask {
                        try await self.addImageAsset(
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
            throw .fromAny(error)
        }
    }

    @discardableResult
    func addImageAsset(
        fromPhotosPickerItem item: PhotosPickerItem,
        undoManager um: UndoManager? = nil
    ) async throws(AssetManagerError) -> UUID {
        let id = try await self.assetManager.addImageAsset(fromPhotosPickerItem: item)
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.removeImage(id, undoManager: um)
            }
        )
        return id
    }

    @discardableResult
    func addImage(fromURL url: URL, undoManager um: UndoManager? = nil) async throws(AssetManagerError) -> UUID {
        let id = try await self.assetManager.addImageAsset(fromURL: url)
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.removeImage(id, undoManager: um)
            }
        )
        return id
    }

    private func registerImage(_ asset: ImageAsset, undoManager um: UndoManager? = nil) {
        Task {
            await self.assetManager.registerImageAsset(asset)
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
            await self.assetManager.removeImageAsset(id)
        }
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.registerImage(asset, undoManager: um)
            }
        )
    }

    func getThumb(forImageAsset id: UUID) async throws -> CGImage? {
        try await self.assetManager.getThumb(forImageAsset: id)
    }

    private func onAssetManagerEvent(_ event: AssetManager.Event) async {
        log("event: \(event)", level: .debug)
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
