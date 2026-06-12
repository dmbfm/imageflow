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
public typealias XPopUpButton = NSPopUpButton
public typealias XButtonSize = NSControl.ControlSize
public typealias XSwitch = NSSwitch
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
    /// Stores a reference to this `XView` in the `target` object at the given key-path,
    /// force-casting the view to the given subclass `V: XView` in the proccess. Because
    /// of this force-casting, this method should be used with care to avoid run-time
    /// errors.
    ///
    /// - Parameters:
    ///   - target: The target object where the reference will be stored.
    ///   - kp: The key-path of where the reference will be stored in `target`
    ///
    /// - Returns: `Self`
    @discardableResult
    func storeRef<R: AnyObject, V: XView>(_ target: R, _ kp: ReferenceWritableKeyPath<R, V>) -> Self {
        target[keyPath: kp] = self as! V
        return self
    }

    /// Stores a reference to this `XView` in the `target` object at the given key-path,
    /// casting the reference to the `V: XView` parameter / sub-type before storing. If
    /// the casting fails nothing is done.
    ///
    /// - Parameters:
    ///   - target: The target object where the reference will be stored.
    ///   - kp: The key-path of the optional where the reference will be stored in `target`
    ///
    /// - Returns: `Self`
    @discardableResult
    func storeRefOpt<R: AnyObject, V: XView>(_ target: R, _ kp: ReferenceWritableKeyPath<R, V?>) -> Self {
        target[keyPath: kp] = self as? V
        return self
    }

    /// Perform a closure `op` on `Sefl` and returns a reference to `Self`.
    /// - Parameter op: The closure.
    /// - Returns: `Self`
    @discardableResult
    func withRef(_ op: (Self) -> ()) -> Self {
        op(self)
        return self
    }

    @discardableResult
    func withLayer(_ op: (CALayer) -> ()) -> Self {
        #if os(macOS)
        self.wantsLayer = true
        if let layer = self.layer {
            op(layer)
        }
        return self
        #else
        op(self.layer)
        #endif
    }

    func constrainingWidth(toConstant value: CGFloat) -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: value).isActive = true
        return self
    }

    func constrainingHeight(toConstant value: CGFloat) -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: value).isActive = true
        return self
    }

    func constrainingSize(toConstant value: CGSize) -> Self {
        self.constrainingWidth(toConstant: value.width)
            .constrainingHeight(toConstant: value.height)
    }

    func withContentHuggingPriority(
        _ priority: NSLayoutConstraint.Priority,
        for orientation: NSLayoutConstraint.Orientation
    ) -> Self {
        self.setContentHuggingPriority(priority, for: orientation)
        return self
    }

    func withContentCompressionResistancePriority(
        _ priority: NSLayoutConstraint.Priority,
        for orientation: NSLayoutConstraint.Orientation
    ) -> Self {
        self.setContentCompressionResistancePriority(priority, for: orientation)
        return self
    }

    @discardableResult
    func constraintToFill(_ view: XView, insets: XEdgeInsets = .init(0)) -> [NSLayoutConstraint] {
        let constraints = [
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    func constraintToFillSuperview(insets: XEdgeInsets = .init(0)) -> [NSLayoutConstraint] {
        if let view = self.superview {
            self.constraintToFill(view, insets: insets)
        } else {
            []
        }
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
