import Helpers
import Logging
import XKit

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

class CanvasContentView: XViewEx {
    #if os(macOS)
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
        for view in self.subviews.reversed() where view.hitTest(localPoint) != nil {
            return super.hitTest(point)
        }

        return nil
    }

    func sortSubviews() {
        self.sortSubviews(
            { a, b, _ in
                guard let a = a as? (any CanvasNodeView), let b = b as? (any CanvasNodeView) else {
                    return .orderedSame
                }

                if a.level == b.level {
                    return .orderedSame
                } else if a.level > b.level {
                    return .orderedDescending
                } else {
                    return .orderedAscending
                }

            },
            context: nil
        )
    }

    #endif

    #if os(iOS)

    func sortSubviews() {
        let sortedSubviews = self.subviews.sorted(by: { a, b in
            guard let a = a as? (any CanvasNodeView), let b = b as? (any CanvasNodeView) else { return false }
            return b.level > a.level
        })
        for v in sortedSubviews {
            self.bringSubviewToFront(v)
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 1) If inside our normal bounds, definitely handle it
        if super.point(inside: point, with: event) {
            return true
        }
        // 2) Otherwise check *all* subviews
        for subview in subviews {
            // Convert the point into that subview’s coordinate system
            let pt = subview.convert(point, from: self)
            // Ask the subview if that point is inside *its* bounds
            if subview.point(inside: pt, with: event) {
                return true
            }
        }
        // 3) Nowhere to go
        return false
    }

    //
    //    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    //        print("hit test: \(point)")
    ////        let localPoint = self.convert(point, from: self.superview)
    //        for view in self.subviews.reversed() {
    //            let localPoint = self.convert(point, to: view)
    //            print("localPoint: \(localPoint)")
    //            if view.hitTest(localPoint, with: event) != nil {
    //                return super.hitTest(point, with: event)
    //            }
    //        }
    //
    //        return nil
    //    }
    #endif
}
