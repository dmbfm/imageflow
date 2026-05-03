import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit
public typealias XPanGestureRecognizer = NSPanGestureRecognizer
#endif

#if canImport(UIKit)
import UIKit
public typealias XPanGestureRecognizer = UIPanGestureRecognizer
#endif
