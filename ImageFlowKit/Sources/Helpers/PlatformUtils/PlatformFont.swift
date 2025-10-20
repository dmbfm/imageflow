#if canImport(UIKit)
import UIKit
public typealias PlatformFont = UIFont
#endif

#if canImport(AppKit)
import AppKit
public typealias PlatformFont = NSFont
#endif
