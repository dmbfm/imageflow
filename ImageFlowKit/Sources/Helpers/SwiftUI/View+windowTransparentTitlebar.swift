#if canImport(AppKit)

import SwiftUI
import AppKit

extension View {
    public func windowTransparentTitlebar() -> some View {
        self.inspectWindow { window in
            guard let window else { return }

            window.styleMask.insert(.fullSizeContentView)
            window.titlebarAppearsTransparent = true
        }
    }
}

#endif
