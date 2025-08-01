import PlatformUtils

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

final class ContentView: PlatformView {
    #if os(macOS)
    override var isFlipped: Bool {
        true
    }

    override var isOpaque: Bool {
        true
    }

    override var wantsDefaultClipping: Bool {
        false
    }
        override func hitTest(_ point: NSPoint) -> NSView? {
        if let event = NSApp.currentEvent, event.type == .otherMouseDown {
            return nil
        }

        let localPoint = self.convert(point, from: self.superview)
        for view in self.subviews.reversed() {
            if view.hitTest(localPoint) != nil {
                return super.hitTest(point)
            }
        }

        return nil
    }

    func sortSubviews() {
        self.subviews.sort { a, b in
            guard let a = a as? (any CanvasNodeView),
                let b = b as? (any CanvasNodeView)
            else { return false }
            return a.level < b.level
        }
    }
    
    #endif
    
    
    #if os(iOS)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }
    #endif
}
