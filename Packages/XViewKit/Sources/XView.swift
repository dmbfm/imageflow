import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit
public typealias XView = NSView
public typealias XViewController = NSViewController
#endif

#if canImport(UIKit)
import UIKit
public typealias XView = UIView
public typealias UIViewController = NSViewController
#endif

public extension XView {
    func withLayer(_ op: (CALayer) -> ()) {
        #if os(macOS)
        self.wantsLayer = true
        if let layer = self.layer {
            op(layer)
        }
        #else
        op(self.layer)
        #endif
    }

    #if os(iOS)
    var wantsLayer: Bool {
        get { false }
        set {}
    }
    #endif

    #if os(macOS)
    func setNeedsLayout() {
        self.needsLayout = true
    }
    #endif
}
