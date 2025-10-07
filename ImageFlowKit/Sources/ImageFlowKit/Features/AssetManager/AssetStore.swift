import Logging
import SwiftUI

@Observable
@MainActor
final class AssetStore {

    private(set) var images: [UUID: ImageAsset] = [:]
    private(set) var thumbs: [UUID: ResourceState<CGImage, AssetManagerError.ThumbError>] = [:]

    let assetManager: AssetManager = .init()

    init() {
        self.assetManager.emitter.on { [weak self] event in
            Task { @MainActor in
                await self?.onAssetManagerEvent(event)
            }
        }
    }

    func setDocumentID(_ id: UUID) {
        Task {
            await self.assetManager.setDocumentID(id)
        }
    }

    func addImage(fromURL url: URL) async throws -> UUID {
        try await self.assetManager.addImageAsset(fromURL: url)
    }

    func startLoadingThum(forImage id: UUID) {
        Task.detached {
            _ = try await self.assetManager.getThumb(forImageAsset: id)
        }
    }

    private func onAssetManagerEvent(_ event: AssetManager.Event) async {
        switch event {
        case .imageAssetsDidChange:
            self.images = await self.assetManager.imageAssets
            log("imageAssetsDidChange: \(self.images)")
        case .thumbsDidChange:
            self.thumbs = await self.assetManager.thumbs
        }
    }
}

extension AssetStore: Storable {
    convenience init(_ data: StorableData) {
        self.init()
        self.images = data.images
    }

    func restore(_ snapshot: StorableData) {
        self.images = snapshot.images
    }

    func snapshot() -> StorableData {
        .init(images: self.images)
    }

    struct StorableData: Sendable, Codable {
        var images: [UUID: ImageAsset] = [:]
    }
}
