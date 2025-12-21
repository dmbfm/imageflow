import SwiftUI
import XViewKit

public protocol CIImageScrollViewCache: AnyObject {
    func get(id: String) -> CIImageScrollView.CacheEntry?
    func set(id: String, value: CIImageScrollView.CacheEntry)
}

extension CIImageScrollView {
    public struct CacheEntry {
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

        view.onEvent = { event in
            Task { @MainActor in
                switch event {
                case .zoomDidChange(let value): self.zoomDidChange?(value)
                }
            }
        }

        if let action = self.action {
            view.dispatch(action)
        }

        return view
    }

    public func updateView(_ view: ViewType, context: Context) {
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
}
