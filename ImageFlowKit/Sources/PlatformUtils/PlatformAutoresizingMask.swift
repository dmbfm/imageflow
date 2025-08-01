#if os(iOS)
import UIKit
public typealias _PlatformAutoresizingMask = UIView.AutoresizingMask
#elseif os(macOS)
import AppKit
public typealias _PlatformAutoresizingMask = NSView.AutoresizingMask
#endif

/// A platform-agnostic autoresizing mask.
public struct PlatfowmAutoresizingMask: Sendable, OptionSet {
    public let rawValue: _PlatformAutoresizingMask.RawValue

    public init(rawValue: _PlatformAutoresizingMask.RawValue) {
        self.rawValue = rawValue
    }

    public static let flexibleLeftMargin = PlatfowmAutoresizingMask(rawValue: {
        #if os(iOS)
        return UIView.AutoresizingMask.flexibleLeftMargin.rawValue
        #else
        return NSView.AutoresizingMask.minXMargin.rawValue
        #endif
    }())

    public static let flexibleWidth = PlatfowmAutoresizingMask(rawValue: {
        #if os(iOS)
        return UIView.AutoresizingMask.flexibleWidth.rawValue
        #else
        return NSView.AutoresizingMask.width.rawValue
        #endif
    }())

    public static let flexibleRightMargin = PlatfowmAutoresizingMask(rawValue: {
        #if os(iOS)
        return UIView.AutoresizingMask.flexibleRightMargin.rawValue
        #else
        return NSView.AutoresizingMask.maxXMargin.rawValue
        #endif
    }())

    public static let flexibleTopMargin = PlatfowmAutoresizingMask(rawValue: {
        #if os(iOS)
        return UIView.AutoresizingMask.flexibleTopMargin.rawValue
        #else
        return NSView.AutoresizingMask.maxYMargin.rawValue
        #endif
    }())

    public static let flexibleHeight = PlatfowmAutoresizingMask(rawValue: {
        #if os(iOS)
        return UIView.AutoresizingMask.flexibleHeight.rawValue
        #else
        return NSView.AutoresizingMask.height.rawValue
        #endif
    }())

    public static let flexibleBottomMargin = PlatfowmAutoresizingMask(rawValue: {
        #if os(iOS)
        return UIView.AutoresizingMask.flexibleBottomMargin.rawValue
        #else
        return NSView.AutoresizingMask.minYMargin.rawValue
        #endif
    }())

    /// Convert our mask set into the platform’s native mask.
    public var platformMask: _PlatformAutoresizingMask {
        return _PlatformAutoresizingMask(rawValue: rawValue)
    }
}

extension PlatformView {
    public func setAutoresizingMask(_ mask: PlatfowmAutoresizingMask) {
        self.autoresizingMask = mask.platformMask
    }
}

