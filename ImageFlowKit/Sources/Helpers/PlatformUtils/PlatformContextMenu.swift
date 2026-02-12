#if os(macOS)
import AppKit

public typealias PlatformMenu = NSMenu
#endif

#if os(iOS)
import UIKit

public typealias PlatformMenu = UIMenu
#endif
