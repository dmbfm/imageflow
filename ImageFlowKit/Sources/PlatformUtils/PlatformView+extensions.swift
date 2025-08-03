//
//  PlatformView+setNeedsDisplay.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 01/08/25.
//

import QuartzCore

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

public extension PlatformView {
    #if os(macOS)
    @inlinable
    @inline(__always)
    func setNeedsDisplay() {
        self.needsDisplay = true
    }
    #endif

    #if os(macOS)
    @inlinable
    @inline(__always)
    func setNeedsLayout() {
        self.needsLayout = true
    }
    #endif

    @inlinable
    @inline(__always)
    func setWantsLayer() {
        #if os(macOS)
        self.wantsLayer = true
        #endif
    }

    @inlinable
    @inline(__always)
    func layer() -> CALayer {
        #if os(macOS)
        self.layer!
        #else
        self.layer
        #endif
    }
}
