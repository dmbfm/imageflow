//
//  Layout.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 11/08/25.
//

import Foundation
import Helpers
import XKit

struct Layout {

    enum Alignment {
        case left
        case right
        case top
        case bottom
        case horizontalCenter
        case verticalCenter
    }

    enum Guide {
        case center
        case min
        case max
        case constant(CGFloat)
    }

    @MainActor
    // swiftlint:disable function_body_length
    static func align(views: [XView], alignment: Alignment, guide: Guide) {
        switch alignment {
        case .left:
            let pos: CGFloat =
                switch guide {
                case .center: views.map { $0.frame.midX }.reduce(0.0, +) / CGFloat(views.count)
                case .min: views.map { $0.frame.minX }.reduce(.infinity, { min($0, $1) })
                case .max: views.map { $0.frame.maxX }.reduce(-.infinity, { max($0, $1) })
                case .constant(let guide): guide
                }
            for view in views {
                view.frame.origin.x = pos
            }
        case .right:
            let pos: CGFloat =
                switch guide {
                case .center: views.map { $0.frame.midX }.reduce(0.0, +) / CGFloat(views.count)
                case .min: views.map { $0.frame.minX }.reduce(.infinity, { min($0, $1) })
                case .max: views.map { $0.frame.maxX }.reduce(-.infinity, { max($0, $1) })
                case .constant(let guide): guide
                }
            for view in views {
                view.frame.origin.x = pos - view.frame.width
            }
        case .top:
            let pos: CGFloat =
                switch guide {
                case .center: views.map { $0.frame.midY }.reduce(0.0, +) / CGFloat(views.count)
                case .min: views.map { $0.frame.minY }.reduce(.infinity, { min($0, $1) })
                case .max: views.map { $0.frame.maxY }.reduce(-.infinity, { max($0, $1) })
                case .constant(let guide): guide
                }
            for view in views {
                view.frame.origin.y = pos
            }
        case .bottom:
            let pos: CGFloat =
                switch guide {
                case .center: views.map { $0.frame.midY }.reduce(0.0, +) / CGFloat(views.count)
                case .min: views.map { $0.frame.minY }.reduce(.infinity, { min($0, $1) })
                case .max: views.map { $0.frame.maxY }.reduce(-.infinity, { max($0, $1) })
                case .constant(let guide): guide
                }
            for view in views {
                view.frame.origin.y = pos - view.frame.height
            }
        case .horizontalCenter:
            let pos: CGFloat =
                switch guide {
                case .center: views.map { $0.frame.midX }.reduce(0.0, +) / CGFloat(views.count)
                case .min: views.map { $0.frame.minX }.reduce(.infinity, { min($0, $1) })
                case .max: views.map { $0.frame.maxX }.reduce(-.infinity, { max($0, $1) })
                case .constant(let guide): guide
                }
            for view in views {
                view.frame.origin.x = pos - view.frame.width * 0.5
            }
        case .verticalCenter:
            let pos: CGFloat =
                switch guide {
                case .center: views.map { $0.frame.midY }.reduce(0.0, +) / CGFloat(views.count)
                case .min: views.map { $0.frame.minY }.reduce(.infinity, { min($0, $1) })
                case .max: views.map { $0.frame.maxY }.reduce(-.infinity, { max($0, $1) })
                case .constant(let guide): guide
                }
            for view in views {
                view.frame.origin.y = pos - view.frame.height * 0.5
            }
        }
    }
}
