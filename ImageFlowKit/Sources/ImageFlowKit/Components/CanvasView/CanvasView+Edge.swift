//
//  CanvasView+CoordinateSpace.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

import Foundation

extension CanvasView {
    struct Edge: Sendable, Equatable, Hashable, Identifiable {
        public var id: UUID
        public var src: CGPoint
        public var dst: CGPoint

        public init(_ id: UUID = UUID(), src: CGPoint, dst: CGPoint) {
            self.id = id
            self.src = src
            self.dst = dst
        }
    }
}
