import CoreImage
import Foundation
import Logging
import Values

protocol AssetBrowserAssetsProvider: AssetBrowserThumbProvider {
    @MainActor
    func assetBrowserAssets(forKinds: Set<AssetKind>) -> [Asset]
}

protocol AssetBrowserThumbProvider {
    func assetBrowserGetThumb(forAsset id: UUID) async throws -> CGImage?
}

extension AssetStore: AssetBrowserThumbProvider {
    func assetBrowserGetThumb(forAsset id: UUID) async throws -> CGImage? {
        try await self.getThumb(forAsset: id)
    }
}

extension AssetStore: AssetBrowserAssetsProvider {
    func assetBrowserAssets(forKinds kinds: Set<AssetKind>) -> [Asset] {
        self.assets.values.filter { kinds.contains($0.kind) }
    }
}
