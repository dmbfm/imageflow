import SwiftUI
import XViewKit

#if os(macOS)
import AppKit
#endif

public final class CardStageView: XCommonView {

    public var state: CardStageState = .default {
        didSet {
            if self.state != oldValue {
                self.delegate?.cardStateStateDidChange(self.state)
                self.stateDidChange()
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

    public weak var delegate: CardStageViewDelegate?

    private var geometry: Geometry = .zero

    lazy var cardView: CardView = {
        let view = CardView()
        return view
    }()

    init(_ state: CardStageState = .default) {
        self.state = state

        super.init(frame: .zero)

        self.addSubview(self.cardView)

        self.setupGestures()
    }

    public required init?(coder: NSCoder) {
        nil
    }

    func setupGestures() {
        let panGesture = XPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler(_:)))
        self.cardView.addGestureRecognizer(panGesture)
    }

    @objc func panGestureHandler(_ gesture: XPanGestureRecognizer) {
        logger.debug("pan: \("\(gesture.translation(in: nil))")")
        switch self.state {
        case .docked(_):
            break
        case .floating(let floating):
            self.handleFloatingDrag(floating, gesture)
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

    func stateDidChange() {
        self.updateGeometry()
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
                self.setNeedsLayout()
            }
        }
    }

    public override func resetCursorRects() {
        self.discardCursorRects()

        if let square = self.geometry.square, let anchor = self.state.anchor {
            let rects = square.resizeRects(anchor: anchor, thickness: 10)
            self.addCursorRect(rects.horizontal, cursor: .windowResizeNorthSouthCursor)
            self.addCursorRect(rects.vertical, cursor: .windowResizeEastWestCursor)
            self.addCursorRect(
                rects.diagonal,
                cursor: {
                    switch anchor {
                    case .topLeft, .bottomRight: .windowResizeNorthWestSouthEastCursor
                    default: .windowResizeNorthEastSouthWestCursor
                    }
                }()
            )
        }
    }

    public override func layout() {
        super.layout()

        self.updateGeometry(false)
        print("geometry: \(self.geometry)")
        print("bounds: \(self.bounds)")

        switch self.geometry {
        case .docked:
            fatalError("TODO")
        case .floating(let geo):
            self.cardView.frame.origin = geo.square.origin
            self.cardView.frame.size = .init(width: geo.square.size, height: geo.square.size)
        }
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

        public init() {}

        public var body: some View {
            ZStack {
                VStack {
                    PreviewRepresentable()
                        .border(.red)
                        .frame(minWidth: 800, minHeight: 600)
                        .padding()
                }
            }
        }
    }

    private struct PreviewRepresentable: XViewRepresentable {
        func makeView(context: Context) -> CardStageView {
            let view = CardStageView()
            return view
        }

        func updateView(_ view: CardStageView, context: Context) {

        }
    }
}

#Preview {
    CardStageView.Preview()
}
