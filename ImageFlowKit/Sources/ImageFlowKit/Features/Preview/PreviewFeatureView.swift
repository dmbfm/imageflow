import CIImageView
import Controls
import Helpers
import Logging
import SwiftUI

public enum PreviewPosition: String, Equatable, CaseIterable {
    case topLeft = "Top Left"
    case bottomLeft = "Bottom Left"
    case topRight = "Top Right"
    case bottomRight = "Bottom Right"
    case bottomDock = "Bottom"
    case topDock = "Top"

    var isDocked: Bool {
        switch self {
        case .bottomDock, .topDock: true
        default: false
        }
    }
}

@Observable
@MainActor
class PreviewFeatureState<F: FlowService, A: AssetStoreService> {

    let flow: F
    let assetStore: A
    var image: CIImage? = nil
    fileprivate var cardSize: Bounded<CGFloat> = .init(50...600, 300)!
    fileprivate var cardAlignment: CardAlignment = .bottomTrailing
    fileprivate var cardDockLocation: CardDockLocation? = nil
    fileprivate var cardDockHeights: CardDockHeights = .init(up: .init(50...1000, 200)!, down: .init(50...1000, 200)!)

    var isDocked: Bool {
        self.cardDockLocation != nil
    }

    var isFloating: Bool {
        !self.isDocked
    }

    var previewPosition: PreviewPosition {
        get {
            switch self.cardDockLocation {
            case .down: .bottomDock
            case .up: .topDock
            case .none:
                switch self.cardAlignment {
                case .topTrailing: .topRight
                case .topLeading: .topLeft
                case .bottomLeading: .bottomLeft
                case .bottomTrailing: .bottomRight
                }
            }
        }

        set {
            let anim: Animation? =
                if !self.previewPosition.isDocked && !newValue.isDocked {
                    .bouncy
                } else {
                    nil
                }

            switch newValue {
            case .bottomDock:
                self.cardDockLocation = .down
            case .topDock:
                self.cardDockLocation = .up
            case .bottomLeft:
                self.cardDockLocation = nil
                withAnimation(anim) {
                    self.cardAlignment = .bottomLeading
                }
            case .bottomRight:
                self.cardDockLocation = nil
                withAnimation(anim) {
                    self.cardAlignment = .bottomTrailing
                }
            case .topLeft:
                self.cardDockLocation = nil
                withAnimation(anim) {
                    self.cardAlignment = .topLeading
                }
            case .topRight:
                self.cardDockLocation = nil
                withAnimation(anim) {
                    self.cardAlignment = .topTrailing
                }
            }
        }
    }

    func observeSelection() async {
        for await sel in Observations({ self.flow.selection }) {
            guard sel.count == 1 else {
                self.image = nil
                continue
            }

            if let id = sel.first, let node = self.flow.nodes[id] {
                if let index = node.outputs
                    .filter({ $0.type == .image })
                    .first
                    .map({ $0.id })
                {
                    if let r = try? await self.assetStore.getGeneratedResource(
                        ciImageAt: .init(node: id, index: index)
                    ) {
                        self.image = r.res
                    } else {
                        self.image = nil
                    }
                } else {
                    self.image = nil
                }
            }
        }
    }

    init(flow: F, assetStore: A) {
        self.flow = flow
        self.assetStore = assetStore

        Task {
            await self.observeSelection()
        }
    }
}

struct PreviewFeatureView<F: FlowService, A: AssetStoreService>: View {

    let state: PreviewFeatureState<F, A>

    var content: PreviewContent {
        if let image = self.state.image {
            .image(image)
        } else {
            .unavailable
        }
    }

    func toolbarAction(_ name: FloatingPreviewContentView.Name) {
        switch name {
        case .dockDown:
            self.state.cardDockLocation = .down
        case .dockUp:
            self.state.cardDockLocation = .up
        case .export:
            log("TODO: export")
        case .lock:
            log("TODO: lock")
        }
    }

    var visibility: CardVisibility {
        if self.state.isDocked {
            .visible
        } else {
            self.state.image == nil ? .hidden : .visible
        }
    }

    public var body: some View {

        @Bindable var state = self.state

        CardStageView(
            $state.cardSize,
            $state.cardAlignment,
            $state.cardDockLocation,
            $state.cardDockHeights,
            visibility: self.visibility,
            padding: .init(width: 25, height: 25),
        ) {
            if self.state.cardDockLocation == nil {
                FloatingPreviewContentView(self.content) { self.toolbarAction($0) }
            } else {
                DockedPreviewContentView(content: self.content)
            }
        }
    }
}

struct DockedPreviewContentView: View {
    let content: PreviewContent

    var body: some View {
        switch content {
        case .image(let image):
            CIImageView(image: image)
                .placement(.fill)
        default:
            Color.white
        }
    }
}
