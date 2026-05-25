//
//  Layout.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 11/08/25.
//

import Foundation
import Helpers

public struct LayoutHelper {

    public enum Alignment {
        case left
        case right
        case top
        case bottom
        case horizontalCenter
        case verticalCenter
    }

    public enum Guide {
        case center
        case min
        case max
        case constant(CGFloat)
    }

    @MainActor
    public static func align(views: [XView], alignment: Alignment, guide: Guide) {
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

@MainActor
public struct VStackLayout {

    @MainActor
    public struct Entry {
        public let view: XView
        public let sizingMode: SizingMode
        // public let flex: Bool

        public enum SizingMode {
            case intrinsic
            case flex(FlexHeight)
            case fixed(CGSize)
        }

        public enum FlexHeight {
            case intrinsic
            case fixed(CGFloat)
        }

        var flex: Bool {
            switch self.sizingMode {
            case .flex: true
            default: false
            }
        }

        var effectivelyFlex: Bool {
            self.width == nil
        }

        var size: CGSize {
            switch self.sizingMode {
            case .fixed(let size): size
            default: self.view.intrinsicContentSize
            }
        }

        var width: CGFloat? {
            switch self.sizingMode {
            case .fixed(let size): size.width
            case .intrinsic, .flex(.intrinsic):
                {
                    let w = view.intrinsicContentSize.width

                    if w == XView.noIntrinsicMetric {
                        return nil
                    } else {
                        return w
                    }
                }()
            case .flex: nil
            }
        }

        var height: CGFloat {
            switch self.sizingMode {
            case .fixed(let size): size.height
            case .intrinsic, .flex(.intrinsic): view.intrinsicContentSize.height
            case .flex(.fixed(let height)): height
            }
        }

        public init(view: XView, sizingMode: SizingMode = .intrinsic) {
            self.view = view
            self.sizingMode = sizingMode
        }
    }

    public enum Spacing {
        case uniform(CGFloat)
        case custom([CGFloat])
    }

    public static func intrinsicContentSize(_ entries: [Entry], _ bounds: CGRect, spacing: Spacing) -> CGSize {
        .init(width: XView.noIntrinsicMetric, height: entries.reduce(0.0, { acc, entry in max(acc, entry.height) }))
    }

    public static func layout(_ entries: [Entry], _ bounds: CGRect, spacing: Spacing) {
        let nonFlexWidthSum = entries.filter({ !$0.effectivelyFlex }).reduce(
            0.0,
            { acc, entry in acc + entry.size.width }
        )
        let nonFlexWidthSumWithSpacings =
            switch spacing {
            case .uniform(let spacing): nonFlexWidthSum + CGFloat(entries.count - 1) * spacing
            case .custom(let spacings): nonFlexWidthSum + spacings.reduce(0.0, +)
            }
        let remainingWidth: CGFloat = bounds.size.width - nonFlexWidthSumWithSpacings
        let flexCount = entries.count(where: { $0.effectivelyFlex })
        let flexWidth: CGFloat =
            if flexCount == 0 {
                0.0
            } else {
                remainingWidth / Double(flexCount)
            }
        let widths = entries.map({ entry in
            if entry.effectivelyFlex {
                flexWidth
            } else {
                entry.size.width
            }
        })
        let heights = entries.map({ entry in
            entry.height
        })

        let maxHeight = heights.reduce(0.0, { acc, height in max(acc, height) })

        let xs = entries.indices.reduce(
            (bounds.origin.x, [CGFloat]()),
            { acc, idx in
                let x0 = acc.0
                let xs = acc.1
                let width = widths[idx]
                let sp =
                    switch spacing {
                    case .uniform(let value): value
                    case .custom(let values):
                        if values.indices.contains(idx) {
                            values[idx]
                        } else {
                            0.0
                        }
                    }
                let next = x0 + width + sp

                return (next, xs + [x0])
            }
        ).1

        let midY = maxHeight * 0.5
        for (view, (x, (width, height))) in zip(entries.map({ $0.view }), zip(xs, zip(widths, heights))) {
            view.frame.origin.x = x
            view.frame.origin.y = midY - height * 0.5
            view.frame.size = .init(width: width, height: height)
        }
    }
}
