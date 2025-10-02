#if canImport(AppKit)

import AppKit

@MainActor
public extension NSEvent {
    func location(inView view: NSView) -> CGPoint {
        view.convert(self.locationInWindow, to: view)
    }
}

#endif
