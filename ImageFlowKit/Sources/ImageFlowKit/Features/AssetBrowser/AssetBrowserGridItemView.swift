import CoreGraphics
import Logging
import SwiftUI

extension AssetBrowserView {
    struct ImageAssetInfo: Equatable, Identifiable {
        var id: UUID
        var name: String
        var added: Date
        var state: State = .loading

        enum State: Equatable {
            case loading
            case loaded
            case failed
        }
    }
}

extension AssetBrowserView {
    struct GridItemView: View {
        let assetStore: AssetStore
        let selected: Bool
        let info: ImageAssetInfo

        @State var image: CGImage?

        func load() {
            Task {
                do {
                    self.image = try await self.assetStore.getThumb(forImageAsset: self.info.id)
                } catch {
                    log("Failed to get thumbnail: \(error)", level: .error)
                }
            }
        }

        var body: some View {
            GridItemInnerView(
                image: self.image,
                name: info.name,
                selected: self.selected,
                failed: self.info.state == .failed
            )
            .onChange(of: self.info, initial: true) {
                self.load()
            }
        }
    }
}
