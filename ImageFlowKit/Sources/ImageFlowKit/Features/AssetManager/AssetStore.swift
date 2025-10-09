import Logging
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

    func addImage(fromURL url: URL) async throws -> UUID {
        try await self.assetManager.addImageAsset(fromURL: url)
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
