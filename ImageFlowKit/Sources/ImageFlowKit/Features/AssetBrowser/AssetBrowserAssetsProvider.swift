import CoreImage
import Foundation
import Logging

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
        log("--> kinds: \(kinds)")
        return self.fileAssets.filter({ kinds.contains($0.kind) })
    }
}
