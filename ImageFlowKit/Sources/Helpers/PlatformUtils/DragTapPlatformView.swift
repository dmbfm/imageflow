#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

open class DragTapPlatformView: PlatformView {

    public var onTapGesture: (() -> ())?
    public var onDragGesture: ((_ phase: GesturePhase, _ deltaX: CGFloat, _ deltaY: CGFloat) -> ())?

    // MARK: - iOS Specific

    #if os(iOS)
    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        isUserInteractionEnabled = true

        // 1. Pan gesture for dragging
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGR)

        // 2. Tap gesture for taps
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        // ensure tap only fires if pan fails (i.e. no movement)
        tapGR.require(toFail: panGR)
        addGestureRecognizer(tapGR)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        self.onDragGesture?(.init(gestureRecognizerState: gesture.state), translation.x, translation.y)
        gesture.setTranslation(.zero, in: superview)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        self.onTapGesture?()
    }
    #endif

    // MARK: - MacOS Specific

    #if os(macOS)
    override public var isFlipped: Bool {
        true
    }

    override public func mouseDown(with event: NSEvent) {

        enum State: Equatable {
            case mouseDown(Date, CGPoint)
            case dragging(Date, CGPoint, CGPoint)
            case done
        }

        var dx: CGFloat = 0
        var dy: CGFloat = 0

        var state: State = .mouseDown(.now, event.location(inView: self))

        let clickTimeMs: Double = 250.0
        let minDragDist: Double = 1.0

        while state != .done {

            guard let event = self.window?.nextEvent(matching: [.leftMouseDragged, .leftMouseUp])
            else {
                break
            }

            let location = event.location(inView: self)

            // log("start: state: \(state), event.type: \(event.type), location: \(location)")

            switch event.type {
            case .leftMouseDragged:

                switch state {

                case let .mouseDown(date, start):
                    let delta = location - start

                    if delta.magnitude >= minDragDist {
                        dx = delta.x
                        dy = delta.y
                        self.onDragGesture?(.began, dx, dy)
                        state = .dragging(date, start, location)
                    }
                    break

                case let .dragging(date, start, prev):
                    dx = location.x - prev.x
                    dy = location.y - prev.y
                    self.onDragGesture?(.changed, dx, -dy)
                    state = .dragging(date, start, location)
                    break
                default:
                    state = .done
                    break
                }

                break
            case .leftMouseUp:
                switch state {
                case .done:
                    break
                case let .dragging(date, start, prev):
                    if (date.timeIntervalSinceNow * 1_000 > -clickTimeMs)
                        && start.distance(to: location) < minDragDist
                    {
                        self.onTapGesture?()
                        state = .done
                    } else {
                        dx = location.x - prev.x
                        dy = location.y - prev.y
                        self.onDragGesture?(.ended, dx, -dy)
                        state = .done
                    }
                    break
                case .mouseDown:
                    self.onTapGesture?()
                    state = .done
                }
            default:
                state = .done
            }
            // log("end: state: \(state)")
        }
    }
    #endif
}
