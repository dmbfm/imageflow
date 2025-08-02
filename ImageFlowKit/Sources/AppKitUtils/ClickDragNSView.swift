import AppKit
import CommonUtils

open class ClickDragNSView: NSView {

    public var onClick: (() -> ())?

    public var onDragGesture: ((_ phase: NSGestureRecognizer.State, _ deltaX: CGFloat, _ deltaY: CGFloat) -> ())?

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
                        self.onClick?()
                        state = .done
                    } else {
                        dx = location.x - prev.x
                        dy = location.y - prev.y
                        self.onDragGesture?(.ended, dx, -dy)
                        state = .done
                    }
                    break
                case .mouseDown:
                    self.onClick?()
                    state = .done
                }
            default:
                state = .done
            }
            // log("end: state: \(state)")
        }
    }
}
