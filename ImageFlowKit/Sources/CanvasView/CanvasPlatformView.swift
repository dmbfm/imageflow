import ColorUtils
import CommonUtils
import CoreGraphics
import Design
import EventEmitter
import Logging
import PlatformUtils
import SwiftUI

public final class CanvasPlatformView: PlatformView {

    // MARK: - Common Public Properties

    public var viewport: CanvasViewport {
        didSet {
            if self.viewport != oldValue {
                self.viewportDidChange()
            }
        }
    }

    public var nodePositions: [UUID: CGPoint] {
        didSet {
            log("nodePositionsDidSet")
            if self.nodePositions != oldValue {
                self.nodePositionsDidChange(oldValue)
            }
        }
    }

    public let configuration: CanvasConfiguration

    public var onEvent: ((Event) -> ())?

    public var viewForNode: (UUID) -> (any CanvasNodeView)?

    public private(set) var nodeViews: [UUID: any CanvasNodeView] = [:]

    // MARK: - Public Types

    public enum Event {
        case viewportDidChange(CanvasViewport)
        case nodePositionsDidChange([UUID: CGPoint])
    }

    // MARK: - Common Private Properties

    private var scaleAtStartOfMagnification: CGFloat = 1.0

    // MARK: - Platform Private Properties

    #if os(macOS)
    private var leftPanInitialPos: CGPoint?
    #endif

    #if os(iOS)
    private var startLoc: CGPoint = .zero
    #endif

    // MARK: - Subviews

    private lazy var gridView: GridView = {
        let view = GridView()
        #if os(macOS)
        view.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .scroll(let event):
                self.gridView(didScrollWith: event)
            default:
                break
            }
        }
        #endif
        view.setAutoresizingMask([.flexibleWidth, .flexibleHeight])
        return view
    }()

    private lazy var contentView: ContentView = {
        let view = ContentView()
        #if os(macOS)
        view.setAutoresizingMask([.flexibleWidth, .flexibleHeight])
        #endif
        return view
    }()

    // MARK: - Initializers

    public init(
        viewport: CanvasViewport,
        nodePositions: [UUID: CGPoint],
        configuration: CanvasConfiguration,
        viewForNode: @escaping (UUID) -> (any CanvasNodeView)?,
    ) {
        self.viewport = viewport
        self.nodePositions = nodePositions
        self.configuration = configuration
        self.viewForNode = viewForNode

        super.init(frame: .zero)

        self.autoresizesSubviews = true
        self.clipsToBounds = true

        self.setupGridView()
        self.setupContentView()

        self.nodePositionsDidChange([:])
        self.gridViewDraw()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        nil
    }

    #if os(macOS)
    func platformInit() {}
    #endif

    #if os(iOS)
    func platformInit() {}
    #endif

    // MARK: - GridView Methods

    func setupGridView() {
        self.gridView.frame = self.bounds
        self.addSubview(self.gridView)

        #if os(iOS)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.gridViewPanGesture(_:)))
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        self.gridView.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(Self.gridViewPinchGesture(_:)))
        self.gridView.addGestureRecognizer(pinchGesture)
        #endif

        #if os(macOS)
        let panGesture = NSPanGestureRecognizer(
            target: self,
            action: #selector(self.gridView(panGesture:))
        )
        // Middle button mask = 00100
        panGesture.buttonMask = 4
        self.gridView.addGestureRecognizer(panGesture)

        let clickGesture = NSClickGestureRecognizer(
            target: self,
            action: #selector(self.gridView(clickGesture:))
        )
        self.gridView.addGestureRecognizer(clickGesture)

        let leftPanGesture = NSPanGestureRecognizer(
            target: self,
            action: #selector(self.gridView(leftPanGesture:))
        )
        self.gridView.addGestureRecognizer(leftPanGesture)

        let magnificationGesture = NSMagnificationGestureRecognizer(
            target: self,
            action: #selector(self.gridView(magnificationGesture:))
        )
        self.gridView.addGestureRecognizer(magnificationGesture)
        #endif
    }

    #if os(iOS)

    @objc
    func gridViewPanGesture(_ gesture: UIPanGestureRecognizer) {
        let t = gesture.translation(in: nil)
        self.viewport.translate(by: t.cgSize * -1.0, in: .screen)
        gesture.setTranslation(.zero, in: nil)
    }

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

    #endif

    #if os(macOS)

    @objc
    func gridView(magnificationGesture gesture: NSMagnificationGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.scaleAtStartOfMagnification = self.viewport.scale
        default:
            let scale = self.scaleAtStartOfMagnification * (1.0 + gesture.magnification)
            let location = gesture.location(in: self.gridView)
            self.viewport.zoom(
                self.configuration.clampZoom(scale),
                atScreenPoint: location
            )
        }
    }

    @objc
    func gridView(didScrollWith event: NSEvent) {
        if event.subtype == .mouseEvent {
            let location = self.gridView.convert(event.locationInWindow, from: nil)

            var scale = self.viewport.scale

            if event.hasPreciseScrollingDeltas {
                scale -= event.scrollingDeltaX
            } else {
                scale -= event.deltaY * self.configuration.scrollWheelSensitivity
            }

            self.viewport.zoom(
                self.configuration.clampZoom(scale),
                atScreenPoint: location
            )

        } else {
            let t = CGSize(width: -event.scrollingDeltaX, height: -event.scrollingDeltaY)
            self.viewport.translate(by: t, in: .screen)
        }
    }

    @objc func gridView(panGesture gesture: NSPanGestureRecognizer) {
        let t = gesture.translation(in: self.gridView)
        gesture.setTranslation(.zero, in: self.gridView)

        let amount = CGSize(
            width: -t.x,
            height: -t.y
        )
        self.viewport.translate(by: amount, in: .screen)
    }

    @objc func gridView(clickGesture gesture: NSClickGestureRecognizer) {
        // self.emitter.emit(.clickBackground)
    }

    @objc func gridView(leftPanGesture gesture: NSPanGestureRecognizer) {

        // let shiftDown = NSEvent.modifierFlags.contains(.shift)

        // if gesture.state == .began {
        //     self.leftPanInitialPos = gesture.location(in: self.gridView)
        //     self.emitter.emit(.rectSelectEvent(.started(shiftDown: shiftDown)))
        //     return
        // }

        // if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
        //     self.leftPanInitialPos = nil
        //     self.rectSelectionView.selectionRect = .zero
        //     self.emitter.emit(.rectSelectEvent(.ended))
        //     return
        // }

        // guard let initial = self.leftPanInitialPos else {
        //     log("initial location not set", level: .error)
        //     return
        // }

        // let gridRect = CGRect(
        //     origin: initial,
        //     size: gesture.translation(in: self.gridView).cgSize
        // )

        // let contentRect = self.contentView.convert(gridRect, from: self.gridView)

        // self.rectSelectionView.selectionRect = gridRect

        // self.emitter.emit(.rectSelectEvent(.modified(shiftDown: shiftDown, rect: contentRect)))
    }
    #endif

    func gridViewDraw() {
        self.gridView.draw(viewport: self.viewport)
    }

    // MARK: - ContentView Methods

    func setupContentView() {
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
    }

    func updateContentView() {
        #if os(macOS)
        self.contentView.bounds = CGRect(
            origin: self.viewport.origin,
            size: self.viewport.convert(
                self.bounds.size,
                from: .screen,
                to: .viewport
            )
        )
        #else
        self.contentView.transform = self.viewport.transform(from: .canvas, to: .screen)
        #endif
    }

    // MARK: - Updates

    func viewportDidChange() {
        self.onEvent?(.viewportDidChange(self.viewport))
        self.gridViewDraw()
        self.updateContentView()
    }

    func nodePositionsDidChange(_ oldValue: [UUID: CGPoint]) {
        for change in oldValue.difference(from: self.nodePositions) {
            switch change {
            case let .added(id, pos):
                self.addNode(id, at: pos)
            case let .removed(id):
                self.removeNode(id)
            case let .modified(id, pos):
                self.moveNode(id, to: pos)
            }
        }
    }

    // MARK: - Node Management

    private func addNode(_ node: some CanvasNodeView, at position: CGPoint) {
        log("addNode at: \(position)")
        node.frame.origin = position
        node.frame.size = node.intrinsicContentSize
        let id = node.id
        node.emitter.on() { [weak self] event in
            guard let self else { return }
            switch event {
            case let .dragGesture(gesture):
                switch gesture.phase {
                case .changed:
                    let amount = self.viewport.convert(
                        .init(width: gesture.dx, height: gesture.dy),
                        from: .screen,
                        to: .canvas
                    )
                    self.translateNode(id, by: amount)
                default:
                    break
                }

            case .sizeChanged:
                node.frame.size = node.intrinsicContentSize
            //                node.setFrameSize(node.intrinsicContentSize)

            case .click:
                // self.emitter.emit(.nodeClicked(id))
                break

            case .other(_):
                break

            }
        }
        self.nodeViews[node.id] = node
        self.contentView.addSubview(node)
        self.contentView.sortSubviews()
    }

    private func addNode(_ id: UUID, at position: CGPoint) {
        if let node = self.viewForNode(id) {
            self.addNode(node, at: position)
        } else {
            log("Missing view for node \(id)")
        }
    }

    private func removeNode(_ id: UUID) {
        guard let node = self.nodeViews[id] else {
            log("Node not found: \(id)")
            return
        }
        self.nodeViews.removeValue(forKey: id)
        node.removeFromSuperview()
    }

    private func moveNode(_ id: UUID, to position: CGPoint) {
        guard let node = self.nodeViews[id] else {
            log("Node not found: \(id)")
            return
        }
        node.frame.origin = position
        self.setNeedsLayout()
    }

    private func translateNode(_ id: UUID, by translation: CGSize) {
        if self.nodePositions[id] == nil {
            log("Node not found: \(id)")
            return
        }

        let newPos = self.nodePositions[id]! + translation.cgPoint
        self.nodePositions[id] = newPos
        self.onEvent?(.nodePositionsDidChange(self.nodePositions))
        // if let view = self.nodeViews[id] {
        //     view.setFrameOrigin(newPos)
        // }
        // self.emitter.emit(.nodeShouldMove(id, newPos))
    }
}

extension CanvasPlatformView {
}

#if os(macOS)
public class BlueSquareView: NSView, CanvasNodeView {
    public var id: UUID
    public var emitter: EventEmitter<CanvasNodeEvent<()>> = .init()

    // Create the button
    private let centerButton: NSButton = {
        let button = NSButton(
            title: "Press Me",
            target: nil,
            action: #selector(handleButtonPress(_:))
        )
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initializers

    public init(id: UUID, frame frameRect: NSRect) {
        self.id = id
        super.init(frame: frameRect)
        setUpView()
    }

    required init?(coder decoder: NSCoder) {
        nil
    }

    // MARK: - Setup

    private func setUpView() {
        // Make view layer-backed and set background color
        wantsLayer = true
        layer?.backgroundColor = NSColor.systemBlue.cgColor

        // Add and center the button
        addSubview(centerButton)
        NSLayoutConstraint.activate([
            centerButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        self.addGestureRecognizer(NSPanGestureRecognizer(target: self, action: #selector(Self.drag(_:))))
    }

    @objc
    func drag(_ gesture: NSPanGestureRecognizer) {
        let t = gesture.translation(in: nil)
        gesture.setTranslation(.zero, in: nil)
        self.emitter.emit(.dragGesture(.init(phase: .init(gestureRecognizerState: gesture.state), dx: t.x, dy: -t.y)))
    }

    // Ensure the view naturally sizes to 200×200
    public override var intrinsicContentSize: NSSize {
        return NSSize(width: 200, height: 200)
    }

    // MARK: - Actions

    @objc private func handleButtonPress(_ sender: NSButton) {
        print("Button pressed!")
    }
}
#else
public class BlueSquareView: UIView, CanvasNodeView {
    public let id: UUID
    public var emitter: EventEmitter<CanvasNodeEvent<()>> = .init()

    // Create the button
    private let centerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Press Me", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initializers

    public init(id: UUID, frame: CGRect) {
        self.id = id
        super.init(frame: frame)
        setUpView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    // MARK: - Setup

    private func setUpView() {
        // Background color
        backgroundColor = .systemBlue
        self.layer.borderColor = .red
        self.layer.borderWidth = 4

        // Add and center the button
        addSubview(centerButton)
        centerButton.addTarget(self, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            centerButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        // Add pan (drag) gesture
        let pan = UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
        addGestureRecognizer(pan)
    }

    // Ensure the view naturally sizes to 200×200 when using Auto Layout
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 200, height: 200)
    }

    // MARK: - Gesture Handling

    @objc private func drag(_ gesture: UIPanGestureRecognizer) {
        // translation(in:) in our superview coordinate space
        let t = gesture.translation(in: superview)
        gesture.setTranslation(.zero, in: superview)
        // Emit drag event (invert y to match Canvas coordinate system)
        emitter.emit(
            .dragGesture(
                .init(
                    phase: .init(gestureRecognizerState: gesture.state),
                    dx: t.x,
                    dy: -t.y
                )
            )
        )
    }

    // MARK: - Actions

    @objc private func handleButtonPress(_ sender: UIButton) {
        print("Button pressed!")
    }
}
#endif
