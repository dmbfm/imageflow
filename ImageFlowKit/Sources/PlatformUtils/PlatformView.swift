#if canImport(AppKit)
import AppKit
public typealias PlatformView = NSView
#endif

#if canImport(UIKit)
import UIKit
public typealias PlatformView = UIView
#endif
