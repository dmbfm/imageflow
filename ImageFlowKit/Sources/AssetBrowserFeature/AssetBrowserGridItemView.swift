import CoreGraphics
import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

struct AssetBrowserGridItemView: View {
    let asset: Asset
    let thumbProvider: any AssetThumbProvider
    let selected: Bool

    @State var failed: Bool = false
    @State var image: CGImage?
    @State var first: Bool = true

    func load() {
        if !self.first { return }
        self.first = false

        Task.immediate {
            do {
                self.image = try await self.thumbProvider.getThumb(forAsset: self.asset.id)
            } catch {
                self.failed = true
            }

            self.failed = false
        }
    }

    var body: some View {
        AssetBrowserGridItemInnerView(
            image: self.image,
            name: asset.filename,
            selected: self.selected,
            failed: self.failed,
        )
        .onChange(of: self.asset, initial: true) {
            self.load()
        }
    }
}

private class PreviewThumbProvider: AssetThumbProvider {
    let gradientImage: CGImage = .verticalGradientImage(
        width: 256,
        height: 256,
        topColor: .init(red: 0.412, green: 0.562, blue: 0.875, alpha: 1.0),
        bottomColor: .init(red: 0.71, green: 0.784, blue: 0.937, alpha: 1.0)
    )!
    func getThumb(forAsset id: UUID) async throws -> CGImage? {
        try await Task.sleep(for: .seconds(2))
        return self.gradientImage
    }
}

#Preview {
    @Previewable @State var asset = Asset(id: .init(), kind: .image, timestamp: .now, state: .loaded(filename: ""))  //Asset(id: .asset(id: .init()), state: .loaded(""), timestamp: .now, kind: .image)
    @Previewable @State var tp = PreviewThumbProvider()
    @Previewable @State var selected = false

    VStack {
        AssetBrowserGridItemView(asset: asset, thumbProvider: tp, selected: selected)
            .onTapGesture {
                selected.toggle()
            }
    }
}
