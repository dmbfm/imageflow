#if canImport(AppKit)
import AppKit
public typealias XColor = NSColor

public extension NSColor {
    static let label: NSColor = .labelColor
    static let secondaryLabel: NSColor = .secondaryLabelColor
    static let tertiaryLabel: NSColor = .tertiaryLabelColor
}

#endif

#if canImport(UIKit)
import UIKit
public typealias XColor = UIColor
#endif
