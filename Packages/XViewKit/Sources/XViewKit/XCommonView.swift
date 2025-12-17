#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

open class XCommonView: XView {
    #if os(macOS)
    open override var isFlipped: Bool {
        true
    }

    open override func layout() {
        super.layout()
        self.doLayout()
    }

    public var contentScale: CGFloat {
        self.window?.backingScaleFactor ?? 2.0
    }

    public func setNeedsLayout() {
        self.needsLayout = true
    }
    #endif

    #if os(iOS)
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.doLayout()
    }
    #endif

    open func doLayout() {
    }
}
