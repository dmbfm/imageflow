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

// private class PreviewThumbProvider: AssetStoreService {

//     required init() {}

//     func addAsset(fromURL url: URL, kind: SharedModels.AssetKind, undoManager um: UndoManager?) async throws -> UUID {
//         .init()
//     }

//     func addAsset(
//         data: Data,
//         filename: String,
//         kind: SharedModels.AssetKind,
//         undoManager um: UndoManager?
//     ) async throws -> UUID {
//         .init()
//     }

//     func removeAsset(_ id: UUID, undoManager um: UndoManager?) {

//     }

//     func titleForAsset(id: Values.AssetIdentifier) -> String? {
//         nil
//     }

//     func getGeneratedResource(
//         ciImageAt port: SharedModels.OutputPortLocation
//     ) async throws -> SharedModels.GeneratedResource<CIImage> {
//         fatalError()
//     }

//     func hasGeneratedResource(ciImageAt port: SharedModels.OutputPortLocation) async -> Bool {
//         false
//     }

//     let assets: [UUID: SharedModels.Asset] = [:]

//     let emitter: Helpers.EventEmitter<SharedModels.AssetStoreServiceEvent> = .init()

//     var delegate: (any SharedModels.AssetStoreServiceDelegate)? = nil

//     let gradientImage: CGImage = .verticalGradientImage(
//         width: 256,
//         height: 256,
//         topColor: .init(red: 0.412, green: 0.562, blue: 0.875, alpha: 1.0),
//         bottomColor: .init(red: 0.71, green: 0.784, blue: 0.937, alpha: 1.0)
//     )!
//     func getThumb(forAsset id: UUID) async throws -> CGImage? {
//         try await Task.sleep(for: .seconds(2))
//         return self.gradientImage
//     }

//     var assetManager: any BackendAssetProvider { fatalError() }
// }

// #Preview {
//     @Previewable @State var asset = Asset(
//         id: .init(),
//         kind: .image,
//         timestamp: .now,
//         state: .loaded(filename: "", originalFilename: "")
//     )
//     @Previewable @State var tp = PreviewThumbProvider()
//     @Previewable @State var selected = false

//     VStack {
//         AssetBrowserGridItemView(asset: asset, thumbProvider: tp, selected: selected)
//             .onTapGesture {
//                 selected.toggle()
//             }
//     }
// }
