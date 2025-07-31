#if canImport(UIKit)
import UIKit
import SwiftUI
import ColorUtils
import CommonUtils
import Design
import Logging

public final class CanvasUIKitView: UIView {

    public var viewport: CanvasViewport {
        didSet {
            self.viewportDidChange()
        }
    }
    
    public let configuration: CanvasConfiguration
    
    public var onEvent: ((Event) -> ())?
    
        // MARK: - Subviews
    private lazy var gridView: GridView = {
        let view = GridView()
        // view.emitter.subscribe { [weak self] event in
        //     guard let self else { return }
        //     switch event {
        //     case .scroll(let event): self.gridView(didScrollWith: event)
        //     case .deleteEdge(let id): self.emitter.emit(.deleteEdge(id))
        //     case .mouseEntered: self.emitter.emit(.mouseEntered)  //log("gridView event: .mouseEntered", level: .debug)
        //     case .mouseLeft: self.emitter.emit(.mouseLeft)  //  log("gridView event: .mouseLeft", level: .debug)
        //     }
        // }
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()

    internal init(viewport: CanvasViewport, configuration: CanvasConfiguration = .init()) {
        self.viewport = viewport
        self.configuration = configuration

        super.init(frame: .zero)

        self.autoresizesSubviews = true

        self.setupGridView()
        self.drawGrid()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func setupGridView() {
        self.gridView.frame = self.bounds
        self.addSubview(self.gridView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.gridViewPanGesture(_:)))
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        self.gridView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(Self.gridViewPinchGesture(_:)))
        self.gridView.addGestureRecognizer(pinchGesture)
    }

    func viewportDidChange() {
        self.onEvent?(.viewportDidChange(self.viewport))
        self.drawGrid()
    }

    func drawGrid() {
        self.gridView.draw(viewport: self.viewport)
    }
    
    // MARK: - User interations
    
    @objc
    func gridViewPanGesture(_ gesture: UIPanGestureRecognizer) {
        let t = gesture.translation(in: nil)
        self.viewport.translate(by: t.cgSize * -1.0, in: .screen)
        gesture.setTranslation(.zero, in: nil)
    }
    
    private var scaleAtStartOfMagnification: CGFloat = 1.0
    private var startLoc: CGPoint = .zero

    @objc
    func gridViewPinchGesture(_ gesture: UIPinchGestureRecognizer) {
        
        if gesture.state == .began {
            self.scaleAtStartOfMagnification = self.viewport.scale
            self.startLoc = gesture.location(in: self.gridView)
        }
        
        let scale = gesture.scale
        let location = gesture.location(in: self.gridView)
        let newZoom = self.scaleAtStartOfMagnification * scale
        self.viewport.zoom(self.configuration.clampZoom(newZoom), atScreenPoint: self.startLoc)
    }
}

extension CanvasUIKitView {
    class GridView: UIView {
        var viewport: CanvasViewport? = nil
        init() {
            super.init(frame: .zero)
            self.backgroundColor = Colors.canvasBackground.platformColor
            self.setNeedsDisplay()
        }

        required init?(coder: NSCoder) {
            nil
        }
        
        func draw(viewport: CanvasViewport) {
            self.viewport = viewport
            self.setNeedsDisplay()
        }

        override func draw(_ rect: CGRect) {
            // tracing.logger.log("draw")

            guard let context = UIGraphicsGetCurrentContext() else {
                return
            }

            if let viewport = self.viewport {
                self.drawBackground(context, viewport)
            }
            // self.drawEdges(context)
        }

        internal var makeCircle: CircleImageDrawer = .init()

        //
        //    override func viewDidChangeEffectiveAppearance() {
        //        self.drawBackgroundCache.appearanceChanged = true
        //        self.makeCircle.invalidateCache()
        //    }
    }

}
extension CanvasUIKitView {
    fileprivate struct Preview: UIViewRepresentable {
        func makeUIView(context: Context) -> CanvasUIKitView {
            CanvasUIKitView(viewport: .init())
        }

        func updateUIView(_ uiView: CanvasUIKitView, context: Context) {
        }

    }
}

#Preview {
    VStack {
        CanvasUIKitView.Preview()
            .border(.gray)
    }
    .padding(10)
}

#endif
