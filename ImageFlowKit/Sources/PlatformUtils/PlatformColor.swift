import ColorUtils

#if canImport(AppKit)
import AppKit
public typealias PlatformColor = NSColor
#endif

#if canImport(UIKit)
import UIKit
public typealias PlatformColor = UIColor
#endif
