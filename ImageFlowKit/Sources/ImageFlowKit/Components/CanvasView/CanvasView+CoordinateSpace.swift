//
//  CanvasView+CoordinateSpace.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

extension CanvasView {
    enum CoordinateSpace: Sendable, Hashable {
        /// This is the coordinate space of the view, that is, relative to the
        /// view's bounds.
        case screen
        /// This coordinate space is the "world space" of the underlying
        /// (virtual) canvas.
        case canvas
        /// This coordinate space represents the portion of the canvas which is
        /// shown in the viewport. It is a translation of the `canvas`
        /// coordinate space.
        case viewport
    }
}
