import AnimKit
import Helpers
import SwiftUI
import XKit

#if os(macOS)
import AppKit
#endif

public final class CardStageView: XViewEx {

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

    public var dockedHeight: CGFloat {
        self.state.dockedHeight ?? self.configuration.dockedHeightRange.ideal
    }

    public weak var delegate: CardStageViewDelegate?

    // MARK: - Private Properties

    private lazy var state: CardStageState = .default(forConfiguration: self.configuration) {
        didSet {
            if self.state != oldValue {
                self.stateDidChange(oldValue)
            }
        }
    }

    private var geometry: Geometry = .zero
    private var dockAnimID: UUID = .init()
    private var isAnimatingViaTransaction: Bool = false

    // MARK: - Lazy Properties

    lazy var cardView: CardView = {
        let view = CardView()
        #if os(macOS)
        view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        #endif

        view.shadowStyle = self.configuration.cardShadow

        return view
    }()

    // MARK: - Initialization

    public init() {
        super.init(frame: .zero)

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
            if self.geometry
                .docked?
                .resizingRect(forLocation: docked.location, thickness: self.configuration.dockedResizeHandleThickness)
                .contains(location) == true
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
                let newHeight =
                    switch docked.location {
                    case .bottom:
                        (docked.height - resizing.translation).clamped(
                            to: self.configuration.dockedHeightRange.range
                        )
                    case .top:
                        (docked.height + resizing.translation).clamped(
                            to: self.configuration.dockedHeightRange.range
                        )
                    }

                self.state = .docked(docked.with(\.state, .idle).with(\.height, newHeight), floating)

            case .idle:
                break
            }

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

            if let handle = self.geometry
                .square?
                .resizeRects(anchor: floating.anchor, thickness: self.configuration.cardResizeHandleThickness)
                .handleContaining(point: location, margin: -2)
            {
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
                self.delegate?.cardStageDidStartResizingCard(self, locationInWindow: gesture.location(in: nil))
            } else {
                self.state = .floating(floating.with(\.state, .dragging(offset: .zero)))
            }

        case .changed:
            switch floating.state {
            case .idle:
                break

            case .dragging:

                let location = self.convert(gesture.location(in: nil), from: nil)

                let maybeDockLocation: CardDockLocation? =
                    if location.y >= self.bounds.maxY - self.configuration.edgeMarginToDockWhileDraggingCard {
                        .bottom
                    } else if location.y <= self.configuration.edgeMarginToDockWhileDraggingCard {
                        .top
                    } else {
                        nil
                    }

                if let maybeDockLocation {
                    self.state = .docked(
                        .init(
                            location: maybeDockLocation,
                            height: floating.dockedHeight ?? self.configuration.dockedHeightRange.ideal,
                            state: .idle
                        ),
                        floating.with(\.state, .idle)
                    )
                } else {
                    self.state = .floating(floating.with(\.state, .dragging(offset: t)))
                }

            case .resizing(let resizing):
                self.state = .floating(floating.with(\.state, .resizing(resizing.with(\.translation, t))))
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

                self.delegate?.cardStageDidFinnishResizingCard(self, locationInWindow: gesture.location(in: nil))

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
        onCompletion: (() -> ())? = nil
    ) {
        self.cardView.layer?.opacity = to

        self.isAnimatingViaTransaction = true
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            onCompletion?()
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

        if self.window == nil { return }

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

        // Anchor changed
        if self.state.anchor != oldValue.anchor {
            self.delegate?.cardStageAnchorDidChange(self)
        }

        // Dock location Changed
        if self.state.dockLocation != oldValue.dockLocation {
            self.delegate?.cardStageDockLocationDidChange(self)
        }

        self.updateGeometry()

        //  Floating -> Docked
        if !self.state.isFloating && oldValue.isFloating {
            if let frame = self.geometry.dockedFrame {

                self.delegate?.cardStageDidStartDocking(self)

                // self.cardView.shadowStyle = nil
                if self.state.hidden {
                    self.cardView.frame = frame
                    self.cardView.radius = 0
                    self.cardView.shadowStyle = nil
                    self.delegate?.cardStageDidFinnishDocking(self)
                    self.animCardOpacity(from: 0.0, to: 1.0, 0.25) {
                    }
                } else {
                    self.cardView.frame = frame
                    self.cardView.radius = 0
                    self.cardView.shadowStyle = nil
                    self.delegate?.cardStageDidFinnishDocking(self)
                }
            }
            // Docked -> Floating
        } else if self.state.isFloating && !oldValue.isFloating {
            if self.state.hidden {
                self.animCardOpacity(from: 1.0, to: 0.0, 0.25) {
                    self.delegate?.cardStageDidStartUndocking(self)
                    self.cardView.radius = self.configuration.cardRadius
                    self.cardView.shadowStyle = self.configuration.cardShadow
                    self.delegate?.cardStageDidFinnishUndocking(self)
                }
            } else {
                self.cardView.frame = self.geometry.square?.rect ?? .zero
                self.cardView.radius = self.configuration.cardRadius
                self.cardView.shadowStyle = self.configuration.cardShadow
                self.delegate?.cardStageDidFinnishUndocking(self)
            }
        } else if !self.state.isFloating && !oldValue.isFloating && self.state.dockLocation != oldValue.dockLocation {
            if let frame = self.geometry.dockedFrame {
                self.cardView.frame = frame
                self.cardView.radius = 0
                self.cardView.shadowStyle = nil
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

        let newGeometry = Geometry.fromState(
            self.state,
            stageBounds: self.safeAreaRect,
            configuration: self.configuration
        )

        if self.geometry != newGeometry {
            self.geometry = newGeometry
            self.window?.invalidateCursorRects(for: self)
            if requestLayout {
                self.setNeedsLayout()
            }
        }
    }

    // MARK: - NSView Lifecycle

    public override func resetCursorRects() {
        self.discardCursorRects()

        if self.state.isFloating, let square = self.geometry.square {
            let rects = square.resizeRects(anchor: self.state.anchor, thickness: 10)
            self.addCursorRect(square.rect, cursor: .arrow)
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

    public override func hitTest(_ point: NSPoint) -> NSView? {
        let point = self.convert(point, from: self.superview)
        if !(self.state.hidden && self.state.isFloating) {
            return self.cardView.hitTest(point)
        } else {
            return nil
        }
    }

    // MARK: - Layout

    public override func layout() {
        super.layout()

        guard !self.isAnimatingViaTransaction else {
            return
        }

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
        case .floating(let geo):
            self.cardView.frame.origin = geo.square.origin
            self.cardView.frame.size = .init(width: geo.square.size, height: geo.square.size)
        }
    }

    func layout(docked: CardStageState.Docked, geometry: Geometry.Docked) {
        self.cardView.frame = geometry.frame
    }
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
            func cardStageDidStartResizingCard(_ sender: CardStageView, locationInWindow: CGPoint) {

            }

            func cardStageDidFinnishResizingCard(_ sender: CardStageView, locationInWindow: CGPoint) {

            }

            func cardStageDidStartDocking(_ sender: CardStageView) {

            }

            func cardStageDidStartUndocking(_ sender: CardStageView) {

            }

            func cardStageDidFinnishUndocking(_ sender: CardStageView) {

            }

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

            func cardStageDidFinnishDocking(_ sender: CardStageView) {

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
