import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit
public typealias XView = NSView
#endif

#if canImport(UIKit)
import UIKit
public typealias XView = UIView
#endif
