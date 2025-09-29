#if canImport(AppKit)

import SwiftUI
import AppKit

private struct WindowAccessorView: NSViewRepresentable {
    let callback: (NSWindow?) -> ()

    func makeNSView(context: Context) -> some NSView {
        let view = ProxyView(self.callback)
        return view
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
    }

    private class ProxyView: NSView {
        let callback: (NSWindow?) -> ()
        init(_ callback: @escaping (NSWindow?) -> ()) {
            self.callback = callback
            super.init(frame: .zero)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            nil
        }
        override func viewDidMoveToWindow() {
            self.callback(self.window)
        }
    }
}

public struct WindowAccessorModifier: ViewModifier {
    let callback: (NSWindow?) -> ()

    public init(_ callback: @escaping (NSWindow?) -> Void) {
        self.callback = callback
    }

    public func body(content: Content) -> some View {
        content.background { WindowAccessorView(callback: self.callback) }
    }
}

public extension View {
    func windowAccessor(_ callback: @escaping (NSWindow?) -> ()) -> some View {
        self.modifier(WindowAccessorModifier(callback))
    }
}

#endif
