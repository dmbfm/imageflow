import AnimKit
import Helpers
import SwiftUI
import XViewKit

#if os(macOS)
import AppKit
#endif

/// A description
@MainActor
class DockAnimation: AnimKit::Animation {

    let label: String? = "Dock Animation"

    var duration: Double = 0.2
    let timingFunc = TimingFunction.easing(.cubic, .easeInOut)
    var started: Bool = false
    var ellapsed: TimeInterval = 0

    struct AnimData {
        var frame: CGRect
        var cornerRadius: CGFloat
    }

    var from: AnimData
    var to: AnimData
    var apply: (AnimData) -> ()
    var didFinnish: (() -> ())?

    init(
        from: DockAnimation.AnimData,
        to: DockAnimation.AnimData,
        apply: @escaping (AnimData) -> (),
        didFinnish: (() -> ())? = nil
    ) {
        self.from = from
        self.to = to
        self.apply = apply
        self.didFinnish = didFinnish

        logger.info("from: \("\(from)"), to: \("\(to)")")
    }

    func start(prev: (any AnimKit.Animation)?) {
        if let prev = prev as? DockAnimation {
            //     logger.info("Some funny business is afoot!")
            // self.duration = prev.duration - prev.ellapsed
            //     self.ellapsed = prev.duration - prev.ellapsed
            self.duration = prev.ellapsed
        }
        // if !self.started {
        //     self.started = true
        // } else {
        //     logger.info("Some funny business is afoot!")
        // }
    }

    func tick(deltaTime: TimeInterval) -> AnimKit.AnimationTickResult {

        let currentFrame = self.timingFunc(
            a: self.from.frame,
            b: self.to.frame,
            t: self.ellapsed,
            duration: self.duration
        )

        let currentRadius = self.timingFunc(
            a: self.from.cornerRadius,
            b: self.to.cornerRadius,
            t: self.ellapsed,
            duration: self.duration
        )

        self.apply(.init(frame: currentFrame, cornerRadius: currentRadius))

        self.ellapsed += deltaTime
        if self.ellapsed >= self.duration {
            self.apply(self.to)
            self.didFinnish?()
            return .done
        } else {
            return .continue
        }
    }
}

public final class CardStageView: XCommonView {

    public var state: CardStageState = .default {
        didSet {
            if self.state != oldValue {
                self.delegate?.cardStateStateDidChange(self.state)
                self.stateDidChange(oldValue)
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

    private var geometry: Geometry = .zero

    private var animController: AnimationController!
    private var dockAnimID: UUID = .init()

    lazy var cardView: CardView = {
        let view = CardView()
        #if os(macOS)
        view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        #endif
        return view
    }()

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
        self.setupLayer()
    }

    public required init?(coder: NSCoder) {
        nil
    }

    func setupLayer() {
        switch self.state {
        case .floating: self.cardView.radius = 10
        case .docked: self.cardView.radius = 0
        }
    }

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
                                docked.height - resizing.translation
                            case .top:
                                docked.height + resizing.translation
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

    var movedToWindow: Bool = false
    public override func viewDidMoveToWindow() {
        self.movedToWindow = true
    }

    func stateDidChange(_ oldValue: CardStageState) {

        guard self.movedToWindow else { return }

        self.updateGeometry()

        if !self.state.isFloating && oldValue.isFloating {
            if let frame = self.geometry.dockedFrame {
                if self.state.hidden {
                    self.cardView.layer?.opacity = 1
                    self.cardView.frame = frame
                    self.cardView.radius = 0
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
                self.cardView.layer?.opacity = 0
                self.cardView.radius = 10
                // self.cardView.frame = self.geometry.square?.rect ?? .zero
                self.needsLayout = true
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
    }

    func configurationDidChange() {
        self.updateGeometry()
    }

    func updateGeometry(_ requestLayout: Bool = true) {
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

    public override func layout() {
        super.layout()

        guard !self.animController.isAnimating else {
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

public protocol CardStageViewDelegate: AnyObject {
    func cardStateStateDidChange(_ state: CardStageState)
}

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

extension CardStageView {
    public struct Preview: View {

        @State var state: CardStageState = .default

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
            self._state = .init(wrappedValue: type.state)
        }

        public var body: some View {
            ZStack {
                VStack {
                    PreviewRepresentable(state: self.$state)
                        .border(.red)
                        .frame(minWidth: 800, minHeight: 600)
                        .padding()

                    Divider()
                    HStack(spacing: 16) {
                        Picker("Anchor", selection: self.$state.anchor) {
                            ForEach(CardStageAnchor.allCases) { anchor in
                                Text(anchor.rawValue)
                                    .tag(anchor)
                            }
                        }

                        Toggle("Hidden", isOn: self.$state.hidden)

                        Spacer()

                        Button("Dock Bottom") {
                            self.state = self.state.docked(.bottom)
                        }
                        .disabled(self.state.dockLocation == .bottom)

                        Button("Dock Top") {
                            self.state = self.state.docked(.top)
                        }
                        .disabled(self.state.dockLocation == .top)

                        Button("Float") {
                            self.state = self.state.undocked()
                        }
                        .disabled(self.state.isFloating)

                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }

    private struct PreviewRepresentable: XViewRepresentable {

        @Binding var state: CardStageState

        func makeView(context: Context) -> CardStageView {
            let view = CardStageView()
            view.state = self.state
            view.delegate = context.coordinator
            view.contentView = NSHostingView(
                rootView:
                    ZStack {
                        Color.orange
                        Text("Card View")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
            )
            return view
        }

        func updateView(_ view: CardStageView, context: Context) {

            context.coordinator.state = self.$state

            if view.state != self.state {
                view.state = self.state
            }
        }

        func makeCoordinator() -> Coordinator {
            .init()
        }

        class Coordinator: CardStageViewDelegate {
            var state: Binding<CardStageState>?
            func cardStateStateDidChange(_ state: CardStageState) {
                if let stateBinding = self.state {
                    Task { @MainActor in
                        stateBinding.wrappedValue = state
                    }
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
