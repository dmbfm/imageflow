//
//  PlatformView+setNeedsDisplay.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 01/08/25.
//

public extension PlatformView {
    #if os(macOS)
    func setNeedsDisplay() {
        self.needsDisplay = true
    }

    func setNeedsLayout() {
        self.needsLayout = true
    }
    #endif
}
