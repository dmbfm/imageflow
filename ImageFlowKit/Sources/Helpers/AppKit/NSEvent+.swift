#if canImport(AppKit)

import AppKit

@MainActor
public extension NSEvent {
    func location(inView view: NSView) -> CGPoint {
        view.convert(self.locationInWindow, to: view)
    }

    func isMouseScrollEvent(touchCount: Int) -> Bool {
        !self.isTrackpadScrollEvent(touchCount: touchCount)
    }

    func isTrackpadScrollEvent(touchCount: Int) -> Bool {
        (touchCount > 0 || self.momentumPhase != []) && self.subtype != .mouseEvent
    }
}

#endif
