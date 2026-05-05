import AnimKit
import Helpers
import SwiftUI
import XViewKit

#if os(macOS)
import AppKit
#endif

public final class CardStageView: XCommonView {

    // MARK: - Public Properties

    public var anchor: CardStageAnchor {
        get {
            self.state.anchor
        }

        set {
            if self.state.anchor != newValue {
                self.state = self.state.settingAnchor(to: newValue)
            }
        }
    }

    public var cardVisibility: CardVisibility {
        get {
            self.state.cardVisibility
        }
        set {
            if self.state.cardVisibility != newValue {
                self.state = self.state.settingCardVisibility(to: newValue)
            }
        }
    }

    public var dockLocation: CardDockLocation? {
        get {
            self.state.dockLocation
        }

        set {
            if self.state.dockLocation != newValue {
                self.state = self.state.settingDockedLocation(to: newValue)
            }
        }
    }

    public var configuration: CardStageConfiguration = .default {
        didSet {
            if self.configuration != oldValue {
                self.configurationDidChange()
            }
        }
    }

    public var contentView: XView {
        get { self.cardView.contentView }
        set { self.cardView.contentView = newValue }
    }

    public weak var delegate: CardStageViewDelegate?

    // MARK: - Private Properties

    private var state: CardStageState = .default {
        didSet {
            if self.state != oldValue {
                self.stateDidChange(oldValue)
            }
        }
    }

    private var geometry: Geometry = .zero
    private var animController: AnimationController!
    private var dockAnimID: UUID = .init()
    private var isAnimatingViaTransaction: Bool = false

    // MARK: - Lazy Properties

    lazy var cardView: CardView = {
        let view = CardView()
        #if os(macOS)
        view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        #endif
        return view
    }()

    // MARK: - Initialization

    init(_ state: CardStageState = .default) {
        self.state = state

        super.init(frame: .zero)

        self.animController = .init(self)

        #if os(macOS)
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        #endif

        self.addSubview(self.cardView)

        self.setupGestures()
    }

    public required init?(coder: NSCoder) {
        nil
    }

    // MARK: - User Interaction

    func setupGestures() {
        let panGesture = XPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler(_:)))
        self.cardView.addGestureRecognizer(panGesture)
    }

    @objc func panGestureHandler(_ gesture: XPanGestureRecognizer) {
        switch self.state {
        case let .docked(docked, floating):
            self.handleDockedDrag(docked, floating, gesture)
        case .floating(let floating):
            self.handleFloatingDrag(floating, gesture)
        }
    }

    func handleDockedDrag(
        _ docked: CardStageState.Docked,
        _ floating: CardStageState.Floating,
        _ gesture: XPanGestureRecognizer
    ) {
        let t = {
            let t = gesture.translation(in: nil)
            return CGSize(width: t.x, height: -t.y)
        }()

        switch gesture.state {
        case .began:
            let location = self.convert(gesture.location(in: nil), from: nil)
            if self.geometry.docked?.resizingRect(forLocation: docked.location, thickness: 10).contains(location)
                == true
            {
                self.state = .docked(
                    docked.with(\.state, .resizing(.init(initialSize: docked.height, translation: 0))),
                    floating
                )
            }
        case .changed:
            switch docked.state {
            case .resizing(let resizing):
                self.state = .docked(
                    docked.with(\.state, .resizing(resizing.with(\.translation, t.height))),
                    floating
                )
            case .idle:
                break
            }
        case .ended:
            switch docked.state {
            case .resizing(let resizing):
                self.state = .docked(
                    docked.with(\.state, .idle).with(
                        \.height,
                        {
                            switch docked.location {
                            case .bottom:
                                (docked.height - resizing.translation).clamped(to: self.configuration.dockedHeightRange)
                            case .top:
                                (docked.height + resizing.translation).clamped(to: self.configuration.dockedHeightRange)
                            }
                        }()
                    ),
                    floating
                )
            case .idle:
                break
            }

            break

        default:
            break
        }
    }

    func handleFloatingDrag(_ floating: CardStageState.Floating, _ gesture: XPanGestureRecognizer) {

        let t = {
            let t = gesture.translation(in: nil)
            return CGSize(width: t.x, height: -t.y)
        }()

        switch gesture.state {
        case .began:

            let location = self.convert(gesture.location(in: nil), from: nil)

            if let handle = self.geometry.square?.resizeRects(anchor: floating.anchor, thickness: 10).handleContaining(
                point: location
            ) {
                self.state = .floating(
                    floating.with(
                        \.state,
                        .resizing(
                            .init(
                                initialSize: floating.size,
                                translation: t,
                                handle: handle
                            )
                        )
                    )
                )
            } else {
                self.state = .floating(floating.with(\.state, .dragging(offset: .zero)))
            }

        case .changed:
            switch floating.state {
            case .idle:
                break
            case .dragging:

                let location = self.convert(gesture.location(in: nil), from: nil)

                if location.y >= self.bounds.maxY - 12 {
                    self.state = .docked(
                        .init(location: .bottom, height: floating.dockedHeight ?? 250, state: .idle),
                        floating.with(\.state, .idle)
                    )
                    break
                } else if location.y <= 12 {
                    self.state = .docked(
                        .init(location: .top, height: floating.dockedHeight ?? 250, state: .idle),
                        floating.with(\.state, .idle)
                    )
                    break
                }

                self.state = .floating(floating.with(\.state, .dragging(offset: t)))
            case .resizing(let resizing):
                self.state = .floating(floating.with(\.state, .resizing(resizing.with(\.translation, t))))
                break
            }

        case .ended:
            switch floating.state {
            case .idle:
                break

            case .dragging:
                if let square = self.geometry.square {
                    let newAnchor = Stage(bounds: self.bounds, insets: self.configuration.insets).closestAnchor(
                        toSquare: square
                    )
                    self.state = .floating(
                        floating
                            .with(\.state, .idle)
                            .with(\.anchor, newAnchor)
                    )

                    if let square = self.geometry.square {
                        self.cardView.animator().frame.origin = square.origin
                    }
                }

            case .resizing:
                self.updateGeometry()

                if let square = self.geometry.square {
                    self.state = .floating(floating.with(\.size, square.size).with(\.state, .idle))
                } else {
                    self.state = .floating(floating.with(\.state, .idle))
                }

            }
        default:
            break
        }
    }

    // MARK: - Animations

    func animCardOpacity(
        from: Float,
        to: Float,
        _ duration: CGFloat,
    ) {
        self.cardView.layer?.opacity = to

        self.isAnimatingViaTransaction = true
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.isAnimatingViaTransaction = false
            self.needsLayout = true
        }

        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.timingFunction = .init(name: .easeInEaseOut)
        fadeAnim.duration = duration
        fadeAnim.fromValue = from
        fadeAnim.toValue = to

        self.cardView.layer?.add(fadeAnim, forKey: "CardFadeOut")
        CATransaction.commit()
    }

    func animCardHide(_ duration: CGFloat, _ opacityDurationFraction: CGFloat) {
        self.cardView.layer?.setAffineTransform(.init(scaleX: 0, y: 0))
        self.cardView.layer?.opacity = 0

        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.timingFunction = .init(name: .easeInEaseOut)
        anim.duration = duration
        anim.fromValue = 1.0
        anim.toValue = 0.0

        let moveAnim = CABasicAnimation(keyPath: "position")
        moveAnim.timingFunction = .init(name: .easeInEaseOut)
        moveAnim.duration = duration
        moveAnim.fromValue = NSValue(point: self.cardView.frame.origin)
        moveAnim.toValue = NSValue(point: self.cardView.frame.center)

        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.timingFunction = .init(name: .linear)
        fadeAnim.duration = duration * opacityDurationFraction
        fadeAnim.fromValue = 1.0
        fadeAnim.toValue = 0.0

        self.cardView.layer?.add(anim, forKey: "CardScale")
        self.cardView.layer?.add(moveAnim, forKey: "CardMove")
        self.cardView.layer?.add(fadeAnim, forKey: "CardFade")
    }

    func animCardShow(_ duration: CGFloat, _ opacityDurationFraction: CGFloat) {
        self.cardView.layer?.setAffineTransform(.init(scaleX: 1, y: 1))
        self.cardView.layer?.opacity = 1

        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.timingFunction = .init(name: .easeInEaseOut)
        anim.duration = duration
        anim.fromValue = 0.0
        anim.toValue = 1.0

        let moveAnim = CABasicAnimation(keyPath: "position")
        moveAnim.timingFunction = .init(name: .easeInEaseOut)
        moveAnim.duration = duration
        moveAnim.fromValue = NSValue(point: self.cardView.frame.center)
        moveAnim.toValue = NSValue(point: self.cardView.frame.origin)

        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.timingFunction = .init(name: .linear)
        fadeAnim.duration = duration * opacityDurationFraction
        fadeAnim.fromValue = 0.0
        fadeAnim.toValue = 1.0

        self.cardView.layer?.add(anim, forKey: "CardScale")
        self.cardView.layer?.add(moveAnim, forKey: "CardMove")
        self.cardView.layer?.add(fadeAnim, forKey: "CardFade")
    }

    // MARK: - Updates

    func stateDidChange(_ oldValue: CardStageState) {

        if self.state.anchor != oldValue.anchor {
            self.delegate?.cardStageAnchorDidChange(self)
        }

        if self.state.dockLocation != oldValue.dockLocation {
            self.delegate?.cardStageDockLocationDidChange(self)
        }

        self.updateGeometry()

        if !self.state.isFloating && oldValue.isFloating {
            if let frame = self.geometry.dockedFrame {
                if self.state.hidden {
                    self.cardView.frame = frame
                    self.cardView.radius = 0
                    self.animCardOpacity(from: 0.0, to: 1.0, 0.25)
                } else {
                    _ = self.animController.start(
                        id: self.dockAnimID,
                        animation: DockAnimation(
                            from: .init(
                                frame: self.cardView.frame,
                                cornerRadius: self.cardView.radius
                            ),
                            to: .init(frame: frame, cornerRadius: 0),
                            apply: { [weak self] data in
                                guard let self else { return }
                                self.cardView.frame = data.frame
                                self.cardView.radius = data.cornerRadius
                            }
                        )
                    )
                }
            }
        } else if self.state.isFloating && !oldValue.isFloating {
            if self.state.hidden {
                self.animCardOpacity(from: 1.0, to: 0.0, 0.25)
            } else {
                _ = self.animController.start(
                    id: self.dockAnimID,
                    animation: DockAnimation(
                        from: .init(
                            frame: self.cardView.frame,
                            cornerRadius: self.cardView.radius
                        ),
                        to: .init(
                            frame: self.geometry.square?.rect ?? .zero,
                            cornerRadius: 10
                        ),
                        apply: { [weak self] data in
                            guard let self else { return }
                            self.cardView.frame = data.frame
                            self.cardView.radius = data.cornerRadius
                        },
                    )
                )
            }
        } else if !self.state.isFloating && !oldValue.isFloating && self.state.dockLocation != oldValue.dockLocation {
            if let frame = self.geometry.dockedFrame {
                _ = self.animController.start(
                    id: self.dockAnimID,
                    animation: DockAnimation(
                        from: .init(frame: self.cardView.frame, cornerRadius: self.cardView.radius),
                        to: .init(frame: frame, cornerRadius: 0),
                        apply: { [weak self] data in
                            guard let self else { return }
                            self.cardView.frame = data.frame
                            self.cardView.radius = data.cornerRadius
                        }
                    )
                )
            }
        }

        if state.isFloating {
            if self.state.anchor != oldValue.anchor {
                self.updateGeometry()
                if let square = self.geometry.square {
                    self.cardView.animator().frame.origin = square.origin
                }
            }

            if self.state.hidden != oldValue.hidden, self.state.isFloating {
                let duration = 0.32
                let opFrac = 0.75
                if self.state.hidden {
                    self.animCardHide(duration, opFrac)
                } else {
                    self.animCardShow(duration, opFrac)
                }
            }
        }

        if !self.state.isFloating && self.cardView.radius != 0 {
            self.cardView.radius = 0
        }
    }

    func configurationDidChange() {
        self.updateGeometry()
    }

    func updateGeometry(_ requestLayout: Bool = true) {
        guard self.window != nil else { return }

        let newGeometry = Geometry.fromState(self.state, stageBounds: self.bounds, configuration: self.configuration)

        if self.geometry != newGeometry {
            self.geometry = newGeometry
            self.window?.invalidateCursorRects(for: self)
            if requestLayout {
                self.needsLayout = true
                // self.setNeedsLayout()
            }
        }
    }

    // MARK: - NSView Lifecycle

    public override func viewDidMoveToWindow() {
        self.updateGeometry()
    }

    public override func resetCursorRects() {
        self.discardCursorRects()

        if self.state.isFloating, let square = self.geometry.square {
            let rects = square.resizeRects(anchor: self.state.anchor, thickness: 10)
            self.addCursorRect(rects.horizontal, cursor: .windowResizeNorthSouthCursor)
            self.addCursorRect(rects.vertical, cursor: .windowResizeEastWestCursor)
            self.addCursorRect(
                rects.diagonal,
                cursor: {
                    switch self.state.anchor {
                    case .topLeft, .bottomRight: .windowResizeNorthWestSouthEastCursor
                    default: .windowResizeNorthEastSouthWestCursor
                    }
                }()
            )
        } else if let geometry = self.geometry.docked, let loc = self.state.dockLocation {
            self.addCursorRect(
                geometry.resizingRect(forLocation: loc, thickness: 10),
                cursor: .windowResizeNorthSouthCursor
            )
        }
    }

    // MARK: - Layout

    public override func layout() {
        super.layout()

        guard !self.animController.isAnimating && !self.isAnimatingViaTransaction else {
            logger.debug("layout: animating; skipping")
            return
        }

        logger.debug("layout: continue: \("\(self.state)"), \("\(self.geometry)")")

        self.updateGeometry(false)

        switch self.state {
        case .floating(let floating):
            self.layout(floating: floating)
        case .docked(let docked, _):
            switch self.geometry {
            case .docked(let geometry):
                self.layout(docked: docked, geometry: geometry)
            case .floating(_):
                logger.error("Invalid geometry!")
            }
        }

    }

    func layout(floating: CardStageState.Floating) {
        switch self.geometry {
        case .docked:
            logger.error("Invalid geometry!")
            break
        case .floating(let geo):
            self.cardView.frame.origin = geo.square.origin
            self.cardView.frame.size = .init(width: geo.square.size, height: geo.square.size)
            logger.info("layout: card frame: \("\(self.cardView.frame)")")
        }
    }

    func layout(docked: CardStageState.Docked, geometry: Geometry.Docked) {
        self.cardView.frame = geometry.frame
    }
}

// MARK: - CardStageViewDelegate

public protocol CardStageViewDelegate: AnyObject {
    func cardStageAnchorDidChange(_ sender: CardStageView)
    func cardStageDockLocationDidChange(_ sender: CardStageView)
}

// MARK: - Helpers

#if os(macOS)
extension NSCursor {
    @MainActor static let windowResizeNorthWestSouthEastCursor =
        NSCursor.value(forKey: "_windowResizeNorthWestSouthEastCursor") as? NSCursor ?? NSCursor.columnResize
    @MainActor static let windowResizeNorthEastSouthWestCursor =
        NSCursor.value(forKey: "_windowResizeNorthEastSouthWestCursor") as? NSCursor ?? NSCursor.columnResize
    @MainActor static let windowResizeEastWestCursor =
        NSCursor.value(forKey: "_windowResizeEastWestCursor") as? NSCursor ?? .columnResize
    @MainActor static let windowResizeNorthSouthCursor =
        NSCursor.value(forKey: "_windowResizeNorthSouthCursor") as? NSCursor ?? .rowResize
}
#endif

// MARK: - Previews

extension CardStageView {
    public struct Preview: View {

        // @State var state: CardStageState = .default

        @State var anchor: CardStageAnchor = .bottomLeft
        @State var dockLocation: CardDockLocation? = nil
        @State var cardVisibility: CardVisibility = .visible

        public enum PreviewType {
            case `default`
            case docked

            var state: CardStageState {
                switch self {
                case .default: .default
                case .docked: .dockedDefault
                }
            }
        }

        public init(_ type: PreviewType = .default) {
        }

        public var body: some View {
            ZStack {
                VStack {
                    PreviewRepresentable(
                        anchor: self.$anchor,
                        dockLocation: self.$dockLocation,
                        cardVisibility: self.$cardVisibility
                    )
                    .border(.red)
                    .frame(minWidth: 800, minHeight: 600)
                    .padding()

                    Divider()
                    HStack(spacing: 16) {
                        Picker("Anchor", selection: self.$anchor) {
                            ForEach(CardStageAnchor.allCases) { anchor in
                                Text(anchor.rawValue)
                                    .tag(anchor)
                            }
                        }

                        Toggle(
                            "Hidden",
                            isOn: .init(
                                get: {
                                    self.cardVisibility == .hidden
                                },
                                set: { newValue in
                                    if newValue {
                                        self.cardVisibility = .hidden
                                    } else {
                                        self.cardVisibility = .visible
                                    }
                                }
                            )
                        )

                        Spacer()

                        Button("Dock Bottom") {
                            self.dockLocation = .bottom
                        }
                        .disabled(self.dockLocation == .bottom)

                        Button("Dock Top") {
                            self.dockLocation = .top
                        }
                        .disabled(self.dockLocation == .top)

                        Button("Float") {
                            self.dockLocation = nil
                        }
                        .disabled(self.dockLocation == nil)

                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }

    private struct PreviewRepresentable: XViewRepresentable {

        @Binding var anchor: CardStageAnchor
        @Binding var dockLocation: CardDockLocation?
        @Binding var cardVisibility: CardVisibility

        func makeView(context: Context) -> CardStageView {
            let view = CardStageView()
            view.anchor = self.anchor
            view.dockLocation = self.dockLocation
            view.cardVisibility = self.cardVisibility
            view.delegate = context.coordinator
            view.contentView = NSHostingView(
                rootView:
                    ZStack {
                        Color.orange
                        VStack {
                            Text("Card View")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Button("Hello") {}
                        }
                    }
            )
            return view
        }

        func updateView(_ view: CardStageView, context: Context) {

            context.coordinator.anchor = self.$anchor
            context.coordinator.dockLocation = self.$dockLocation
            context.coordinator.cardVisibility = self.$cardVisibility

            if view.anchor != self.anchor {
                view.anchor = self.anchor
            }

            if view.dockLocation != self.dockLocation {
                view.dockLocation = self.dockLocation
            }

            if view.cardVisibility != self.cardVisibility {
                view.cardVisibility = self.cardVisibility
            }
        }

        func makeCoordinator() -> Coordinator {
            .init()
        }

        @MainActor
        class Coordinator: CardStageViewDelegate {
            var anchor: Binding<CardStageAnchor>?
            var dockLocation: Binding<CardDockLocation?>?
            var cardVisibility: Binding<CardVisibility>?

            func cardStageAnchorDidChange(_ sender: CardStageView) {
                guard let anchor = self.anchor else { return }

                if anchor.wrappedValue != sender.anchor {
                    anchor.wrappedValue = sender.anchor
                }
            }

            func cardStageDockLocationDidChange(_ sender: CardStageView) {
                guard let dockLocation = self.dockLocation else { return }

                if dockLocation.wrappedValue != sender.dockLocation {
                    dockLocation.wrappedValue = sender.dockLocation
                }
            }

        }
    }
}

#Preview("Default") {
    CardStageView.Preview()
}

#Preview("Docked") {
    CardStageView.Preview(.docked)
}
