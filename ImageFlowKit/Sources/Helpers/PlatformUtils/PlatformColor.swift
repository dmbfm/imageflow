#if canImport(AppKit)
import AppKit
public typealias PlatformColor = NSColor

public extension NSColor {
    static let label: NSColor = .labelColor
}

#endif

#if canImport(UIKit)
import UIKit
public typealias PlatformColor = UIColor
#endif
