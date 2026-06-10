#if canImport(AppKit)
import AppKit
public typealias XEdgeInsets = NSEdgeInsets

extension NSEdgeInsets: @retroactive Equatable {
    public static func == (lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
        lhs.top == rhs.top && lhs.bottom == rhs.bottom && lhs.left == rhs.left && lhs.right == rhs.right
    }

    public init(_ value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}

#endif

#if canImport(UIKit)
import UIKit
public typealias XEdgeInsets = UIEdgeInsets
#endif

public extension XEdgeInsets {
    var size: CGSize {
        .init(width: self.left + self.right, height: self.top + self.bottom)
    }
}
