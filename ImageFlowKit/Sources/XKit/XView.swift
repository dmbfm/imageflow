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
public typealias XViewController = UIViewController

extension UIView.AutoresizingMask {
    static let width: Self = .flexibleWidth
    static let height: Self = .flexibleHeight
}

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

    #if os(macOS)
    func setNeedsLayout() {
        self.needsLayout = true
    }

    func setNeedsDisplay() {
        self.needsDisplay = true
    }
    func layoutIfNeeded() {
        self.layoutSubtreeIfNeeded()
    }
    #endif
}
