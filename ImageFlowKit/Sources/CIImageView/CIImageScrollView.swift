import SwiftUI
import XKit

public protocol CIImageScrollViewCache: AnyObject {
    func get(id: String) -> CIImageScrollView.CacheEntry?
    func set(id: String, value: CIImageScrollView.CacheEntry)
}

extension CIImageScrollView {
    public struct CacheEntry: Sendable, Codable {
        public var position: CGPoint
        public var scale: CGFloat
    }
}

public struct CIImageScrollView: XViewRepresentable {

    let id: String
    let image: CIImage?
    let cache: (any CIImageScrollViewCache)?
    let configuration: Configuration
    var zoomDidChange: ((CGFloat) -> ())?
    @Binding var action: Action?

    public typealias Configuration = CIImageScrollXView.Configuration
    public typealias Action = CIImageScrollXView.Action

    public init(
        id: String = "",
        image: CIImage?,
        configuration: Configuration = .init(),
        action: Binding<Action?>,
        cache: (any CIImageScrollViewCache)? = nil,
        zoomDidChange: ((CGFloat) -> ())? = nil
    ) {
        self.image = image
        self.configuration = configuration
        self._action = action
        self.cache = cache
        self.id = id
        self.zoomDidChange = zoomDidChange
    }

    public func makeView(context: Context) -> CIImageScrollXView {
        let view = CIImageScrollXView(
            frame: .zero,
            configuration: self.configuration,
        )

        view.image = image
        view.delegate = context.coordinator

        // view.onEvent = { [weak coordinator = context.coordinator] event in
        //     coordinator?.onEvent(event)
        // }

        if let action = self.action {
            view.dispatch(action)
        }

        return view
    }

    public func updateView(_ view: ViewType, context: Context) {

        context.coordinator.zoomDidChange = self.zoomDidChange

        if view.image != self.image {
            view.image = self.image
        }

        if let action = self.action {
            view.dispatch(action)
            Task { @MainActor in
                self.action = nil
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(zoomDidChange: self.zoomDidChange)
    }

    public class Coordinator: CIImageScrollXViewDelegate {
        var zoomDidChange: ((CGFloat) -> ())? = nil

        init(zoomDidChange: ((CGFloat) -> ())? = nil) {
            self.zoomDidChange = zoomDidChange
        }

        public func ciImageScrollViewViewportDidChange(_ view: CIImageScrollXView, _ viewport: CGRect) {
        }

        public func ciImageScrollViewZoomDidChange(_ view: CIImageScrollXView, _ zoom: CGFloat) {
        }
    }
}
