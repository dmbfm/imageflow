import SwiftUI
import XViewKit

public protocol CIImageScrollViewCache: AnyObject {
    func get(id: String) -> CIImageScrollView.CacheEntry?
    func set(id: String, value: CIImageScrollView.CacheEntry)
}

extension CIImageScrollView {
    public struct CacheEntry: Sendable, Codable {
        var position: CGPoint
        var scale: CGFloat
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
            id: self.id,
            configuration: self.configuration,
            cache: self.cache
        )

        view.image = image

        view.onEvent = { [weak coordinator = context.coordinator] event in
            coordinator?.onEvent(event)
        }

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

        if self.id != view.id {
            view.id = self.id
        }

        view.cache = self.cache
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(zoomDidChange: self.zoomDidChange)
    }

    public class Coordinator {
        var zoomDidChange: ((CGFloat) -> ())? = nil

        init(zoomDidChange: ((CGFloat) -> ())? = nil) {
            self.zoomDidChange = zoomDidChange
        }

        func onEvent(_ event: CIImageScrollXView.Event) {
            switch event {
            case .zoomDidChange(let zoom): self.zoomDidChange?(zoom)
            }
        }
    }
}
