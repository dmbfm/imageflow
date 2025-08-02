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
    
    func sortSubviews() {}
   
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
