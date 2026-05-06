import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit
public typealias XGestureRecognizer = NSGestureRecognizer
public typealias XPanGestureRecognizer = NSPanGestureRecognizer
#endif

#if canImport(UIKit)
import UIKit
public typealias XGestureRecognizer = UIGestureRecognizer
public typealias XPanGestureRecognizer = UIPanGestureRecognizer
#endif
