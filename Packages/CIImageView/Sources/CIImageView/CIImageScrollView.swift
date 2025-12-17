import SwiftUI
import XViewKit

public struct CIImageScrollView: XViewRepresentable {

    let image: CIImage?
    let configuration: Configuration
    @Binding var action: Action?
    @Binding var zoom: CGFloat

    public typealias Configuration = CIImageScrollXView.Configuration
    public typealias Action = CIImageScrollXView.Action

    public init(
        image: CIImage?,
        configuration: Configuration = .init(),
        zoom: Binding<CGFloat>,
        action: Binding<Action?>
    ) {
        self.image = image
        self.configuration = configuration
        self._action = action
        self._zoom = zoom
    }

    public func makeView(context: Context) -> CIImageScrollXView {
        let view = CIImageScrollXView(frame: .zero, configuration: self.configuration)
        view.image = image

        view.onEvent = { event in
            Task { @MainActor in
                switch event {
                case .zoomDidChange(let value): self.zoom = value
                }
            }
        }

        if let action = self.action {
            view.dispatch(action)
        }

        Task { @MainActor in
            self.zoom = view.zoom
        }

        return view
    }

    public func updateView(_ view: ViewType, context: Context) {
        if view.image != self.image {
            view.image = self.image
        }

        if abs(view.zoom - self.zoom) > 0.0001 && !view.isAnimating {
            view.dispatch(.setZoom(value: self.zoom, animate: false))
        }

        if let action = self.action {
            print("action: \(action)")
            view.dispatch(action)
            Task { @MainActor in
                self.action = nil
            }
        }
    }
}
