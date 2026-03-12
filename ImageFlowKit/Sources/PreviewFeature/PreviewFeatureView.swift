import CIImageView
import Controls
import Design
import Helpers
import ImageExporter
import Logging
import SharedMocking
import SharedModels
import SwiftUI

@MainActor
class ScrollCache: @MainActor CIImageScrollViewCache {

    typealias Entry = CIImageScrollView.CacheEntry

    var cache: [String: Entry] = [:]

    init() {
        self.cache = [:]
    }

    func get(id: String) -> Entry? {
        let result = self.cache[id]
        return result
    }

    func set(id: String, value: Entry) {
        self.cache[id] = value
    }
}

public struct PreviewFeatureView: View {

    @ObservableState var state: PreviewFeatureState
    @Environment(\.openWindow) var openWindow

    public init(
        _ flow: Flow,
        _ assetStore: some AssetStoreService,
        coordinator: GlobalCoordinator
    ) {
        self._state = .init(wrappedValue: .init(flow: flow, assetStore: assetStore, coordinator: coordinator))
    }

    var visibility: CardVisibility {
        if self.state.isDocked {
            .visible
        } else {
            self.state.image == nil ? .hidden : .visible
        }
    }

    private let style: PreviewFeatureViewStyle = .default

    public var body: some View {

        @Bindable var state = self.state

        #if os(macOS)
        let dockedStyle: DockedPreviewContentView.Style = .classic
        #else
        let dockedStyle: DockedPreviewContentView.Style = .glass
        #endif

        CardStageView(
            $state.cardSize,
            $state.cardAlignment,
            $state.cardDockLocation,
            $state.cardDockHeights,
            visibility: self.visibility,
            padding: self.style.padding,
            dockedDragHandleHeight: self.style.dokcedDragHandleHeight,
            dockedContentPadding: self.style.dockedContentPadding,
            debugDrawDockedDragHandleArea: false,
        ) {
            if self.state.cardDockLocation == nil {
                FloatingPreviewContentView(
                    vm: self.state.previewContentViewModel,
                    dispatch: self.state.dispatch(_:)
                )
            } else {
                DockedPreviewContentView(
                    vm: self.state.previewContentViewModel,
                    dockLocation: self.state.cardDockLocation!,
                    style: self.style.dockedPreviewStyle,
                    cache: self.state,
                    dispatch: self.state.dispatch(_:)
                )
            }
        }
        .onGeometryChange(for: CGSize.self, of: { $0.size }, action: { self.state.viewSizeDidChange($0) })
        .ignoresSafeArea(.keyboard)
        .activeViewObject(self.state)
    }
}

struct PreviewFeatureViewStyle: Sendable, Equatable {
    var padding: CGSize
    var dokcedDragHandleHeight: CGFloat
    var dockedContentPadding: CGFloat
    var dockedPreviewStyle: DockedPreviewContentView.Style

    static var iOS: Self {
        .init(
            padding: .init(width: 25, height: 25),
            dokcedDragHandleHeight: 30,
            dockedContentPadding: 0,
            dockedPreviewStyle: .glass,
        )
    }

    static var macOS: Self {
        .init(
            padding: .init(width: 25, height: 25),
            dokcedDragHandleHeight: 12,
            dockedContentPadding: 6,
            dockedPreviewStyle: .classic,
        )
    }

    static var `default`: Self {
        #if os(macOS)
        .macOS
        #else
        .iOS
        #endif
    }
}

enum PreviewContentViewAction {
    case dockDown
    case dockUp
    case undock
    case toggleLock
    case export
    case copy
    case dockOpposite
    case openWindow
    case pick(OutputPortLocation)
}

// MARK: - Previews

private func makeTestPlaceholderImage(size: CGFloat = 512) -> CIImage {
    let extent = CGRect(x: 0, y: 0, width: size, height: size)

    // Background
    let background = CIImage(color: .gray)
        .cropped(to: extent)

    // Grid
    let grid = CIFilter.checkerboardGenerator()
    grid.color0 = CIColor(red: 0.85, green: 0.85, blue: 0.85)
    grid.color1 = CIColor(red: 0.65, green: 0.65, blue: 0.65)
    grid.width = 32
    grid.center = CGPoint(x: 0, y: 0)

    let gridImage = grid.outputImage!
        .cropped(to: extent)

    // Crosshair
    let vertical = CIImage(color: .red)
        .cropped(to: CGRect(x: size / 2 - 1, y: 0, width: 2, height: size))

    let horizontal = CIImage(color: .red)
        .cropped(to: CGRect(x: 0, y: size / 2 - 1, width: size, height: 2))

    // Color corner markers
    let corners: [(CIColor, CGRect)] = [
        (.blue, CGRect(x: 0, y: size - 64, width: 64, height: 64)),  // top-left
        (.green, CGRect(x: size - 64, y: size - 64, width: 64, height: 64)),  // top-right
        (.yellow, CGRect(x: 0, y: 0, width: 64, height: 64)),  // bottom-left
        (.magenta, CGRect(x: size - 64, y: 0, width: 64, height: 64)),  // bottom-right
    ]

    let cornerImages = corners.map { color, rect in
        CIImage(color: color).cropped(to: rect)
    }

    // Composite everything
    return ([background, gridImage, vertical, horizontal] + cornerImages)
        .reduce(background) { image, overlay in
            overlay.composited(over: image)
        }
}

@Observable
@MainActor
private final class MockAssetStore: AssetStoreService {
    var assetManager: any BackendAssetProvider {
        fatalError()
    }

    var assets: [UUID: SharedModels.Asset] = [:]

    var delegate: SharedModels.AssetStoreServiceDelegate?

    func getThumb(forAsset id: UUID) async throws -> CGImage? {
        nil
    }

    var emitter: EventEmitter<AssetStoreServiceEvent> = .init()

    func hasGeneratedResource(ciImageAt port: OutputPortLocation) async -> Bool {
        true
    }

    var image: CIImage? = nil

    func genImage() async -> CIImage {
        let task = Task.detached {
            makeTestPlaceholderImage()
        }

        return await task.value
    }

    func getGeneratedResource(ciImageAt port: OutputPortLocation) async throws -> GeneratedResource<CIImage> {
        if self.image == nil {
            self.image = await self.genImage()
        }

        return .init(id: port, timestamp: .now, res: self.image!)
    }
}

#Preview {
    ZStack {
        Colors.canvasBackground.color
        PreviewFeatureView(Flow(), MockAssetStore(), coordinator: .init(MockGlobalCoordinatorService(flow: Flow())))
    }
    .frame(minWidth: 800, minHeight: 600)
}
