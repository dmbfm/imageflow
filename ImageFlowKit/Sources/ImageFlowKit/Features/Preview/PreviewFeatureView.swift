import CIImageView
import Controls
import Helpers
import Logging
import SwiftUI

struct PreviewFeatureView<F: FlowService, A: AssetStoreService>: View {

    let state: PreviewFeatureState<F, A>

    var content: PreviewContent {
        self.state.previewContent
    }

    var visibility: CardVisibility {
        if self.state.isDocked {
            .visible
        } else {
            self.state.image == nil ? .hidden : .visible
        }
    }

    // TODO: Move this to PreviewFeatureState
    func previewViewDispatch(_ action: PreviewContentViewAction) {
        switch action {
        case .undock:
            self.state.cardDockLocation = nil
        case .toggleLock:
            self.state.toggleLocked()
        case .dockDown:
            self.state.cardDockLocation = .down
        case .dockUp:
            self.state.cardDockLocation = .up
        case .dockOpposite:
            self.state.cardDockLocation = self.state.cardDockLocation.map { if $0 == .down { .up } else { .down } }
        case .export:
            log("TODO: export")
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
                FloatingPreviewContentView(
                    vm: self.state.previewContentViewModel,
                    dispatch: self.previewViewDispatch(_:)
                )
            } else {
                DockedPreviewContentView<DefaultToolbarView>(
                    vm: self.state.previewContentViewModel,
                    dispatch: self.previewViewDispatch(_:)
                )
            }
        }
    }
}

#if os(macOS)
typealias DefaultToolbarView = ClassicToolbarView
#else
typealias DefaultToolbarView = GlassToolbarView
#endif

struct PreviewContentViewModel {
    var content: PreviewContent
    var isLocked: Bool
    var lockButtonDisabled: Bool
    var dockLocation: CardDockLocation?
}

enum PreviewContentViewAction {
    case dockDown
    case dockUp
    case undock
    case toggleLock
    case export
    case dockOpposite
}
