import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit
public typealias XView = NSView
public typealias XViewController = NSViewController
public typealias XImageView = NSImageView
public typealias XImage = NSImage
public typealias XLabel = NSTextField
public typealias XStackView = NSStackView
public typealias XButton = NSButton
public typealias XEvent = NSEvent
public typealias XScrollView = NSScrollView
public typealias XStepper = NSStepper
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
