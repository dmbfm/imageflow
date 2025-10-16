import CoreGraphics
import Logging
import SwiftUI

protocol AssetBrowserThumbProvider {
    func getThumb(forImageAsset id: UUID) async throws -> CGImage?
}

extension AssetStore: AssetBrowserThumbProvider {}

struct AssetBrowserGridItemView: View {
    let asset: ImageAsset
    let thumbProvider: any AssetBrowserThumbProvider
    let selected: Bool

    @State var failed: Bool = false

    @State var image: CGImage?

    func load() {
        Task {
            do {
                self.image = try await self.thumbProvider.getThumb(forImageAsset: self.asset.id)
            } catch {
                self.failed = true
                log("Failed to get thumbnail: \(error)", level: .error)
            }

            self.failed = false
        }
    }

    var body: some View {
        AssetBrowserGridItemInnerView(
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

private class PreviewThumbProvider: AssetBrowserThumbProvider {
    let gradientImage: CGImage = .verticalGradientImage(
        width: 256,
        height: 256,
        topColor: .init(red: 0.412, green: 0.562, blue: 0.875, alpha: 1.0),
        bottomColor: .init(red: 0.71, green: 0.784, blue: 0.937, alpha: 1.0)
    )!
    func getThumb(forImageAsset id: UUID) async throws -> CGImage? {
        try await Task.sleep(for: .seconds(2))
        return self.gradientImage
    }
}

#Preview {
    @Previewable @State var asset = ImageAsset(id: .init(), state: .loaded(.file("")), added: .now)
    @Previewable @State var tp = PreviewThumbProvider()
    @Previewable @State var selected = false

    VStack {
        AssetBrowserGridItemView(asset: asset, thumbProvider: tp, selected: selected)
            .onTapGesture {
                selected.toggle()
            }
    }
}
