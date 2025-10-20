#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

open class PlatformCommonView: PlatformView {
    #if os(macOS)
    open override var isFlipped: Bool {
        true
    }

    open override func layout() {
        super.layout()
        self.doLayout()
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
