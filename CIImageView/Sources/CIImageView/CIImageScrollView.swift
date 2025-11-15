import AppKit
import SwiftUI

public struct CIImageScrollView: NSViewRepresentable {

    private var image: CIImage?
    private var zoom: Binding<CGFloat>? = nil
    private var pixelInfo: Binding<CIImageNSView.PixelInfo?>? = nil
    private var getRef: ((Coordinator) -> ())? = nil

    public enum Action {
        case zoom(CGFloat)
        case fit(animate: Bool = false)
        case actualSize
    }

    public init(
        image: CIImage? = nil,
        zoom: Binding<CGFloat>? = nil,
        pixelInfo: Binding<CIImageNSView.PixelInfo?>? = nil,
        getRef: ((Coordinator) -> ())? = nil
    ) {
        self.image = image
        self.zoom = zoom
        self.getRef = getRef
        self.pixelInfo = pixelInfo
    }

    public func makeNSView(context: Context) -> CIImageScrollNSView {
        let view = CIImageScrollNSView(frame: .zero)
        if let pixelInfo = self.pixelInfo {
            view.imageView.onMouseOver = { info in
                pixelInfo.wrappedValue = info
            }
        }
        view.zoomDidChange = { zoom in
            Task { @MainActor in
                self.zoom?.wrappedValue = zoom
            }
        }
        context.coordinator.view = view
        Task { @MainActor in
            self.getRef?(context.coordinator)
        }
        return view
    }

    public func updateNSView(_ view: CIImageScrollNSView, context: Context) {
        if self.image != view.image {
            view.image = self.image
        }

        if let pixelInfo = self.pixelInfo {
            view.imageView.onMouseOver = { info in
                pixelInfo.wrappedValue = info
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    @MainActor
    public class Coordinator {
        internal weak var view: CIImageScrollNSView? = nil

        public func dispatch(_ action: Action) {
            switch action {
            case .zoom(let value):
                self.view?.zoom(value)
            case .actualSize:
                self.view?.zoomActualSize()
            case .fit(let animate):
                self.view?.zoomToFit(animate)
            }
        }

    }
}
