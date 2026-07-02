import AssetSystem
import CoreGraphics
import Helpers
import SharedModels
import SwiftUI
import Values

struct AssetBrowserGridItemView: View {
    let asset: Asset
    let assetStore: AssetStore
    let selected: Bool

    @State var failed: Bool = false
    @State var image: CGImage?
    @State var first: Bool = true

    func load() {
        guard self.asset.isLoaded else { return }

        Task.immediate {
            self.failed = false
            do {
                self.image = try await self.assetStore.resourceManager.fetch(cgImageThumb: .asset(self.asset.id))
            } catch {
                logger.error("failed: \(error)")
                self.failed = true
            }
        }
    }

    var body: some View {
        AssetBrowserGridItemInnerView(
            image: self.image,
            name: asset.originalFilename,
            selected: self.selected,
            failed: self.failed,
        )
        .onChange(of: self.asset, initial: true) {
            self.load()
        }
    }
}
