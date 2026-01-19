//
//  CanvasView+CoordinateSpace.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

import Foundation

extension CanvasView {
    public struct Edge: Sendable, Equatable, Hashable {
        public var src: CGPoint
        public var dst: CGPoint

        public init(src: CGPoint, dst: CGPoint) {
            self.src = src
            self.dst = dst
        }
    }
}
