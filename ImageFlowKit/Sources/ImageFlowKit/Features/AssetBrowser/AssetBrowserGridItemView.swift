import CoreGraphics
import Logging
import SwiftUI

extension AssetBrowserView {
    struct GridItemView: View {
        let asset: ImageAsset
        let assetStore: AssetStore
        let selected: Bool

        @State var failed: Bool = false

        @State var image: CGImage?

        func load() {
            Task {
                do {
                    self.image = try await self.assetStore.getThumb(forImageAsset: self.asset.id)
                } catch {
                    self.failed = true
                    log("Failed to get thumbnail: \(error)", level: .error)
                }

                self.failed = false
            }
        }

        var body: some View {
            GridItemInnerView(
                image: self.image,
                name: asset.source?.filename,
                selected: self.selected,
                failed: self.failed,
            )
            .onChange(of: self.asset, initial: true) {
                self.load()
            }
        }
    }
}
