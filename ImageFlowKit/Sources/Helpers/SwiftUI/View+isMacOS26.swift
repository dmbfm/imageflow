import SwiftUI

extension View {
    public var isMacOS26: Bool {
        #if os(macOS)
        if #available(macOS 26, *) {
            true
        } else {
            false
        }
        #else
        false
        #endif
    }

    public var isIOS26: Bool {
        #if os(iOS)
        if #available(iOS 26, *) {
            true
        } else {
            false
        }
        #else
        false
        #endif
    }
}
