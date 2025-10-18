#if canImport(AppKit)

import SwiftUI
import AppKit

private struct WindowInspectorView: NSViewRepresentable {

    let perform: (NSWindow?) -> ()

    func makeNSView(context: Context) -> some NSView {
        Inner(perform: self.perform)
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {

    }

    private class Inner: NSView {

        let perform: (NSWindow?) -> ()

        init(perform: @escaping (NSWindow?) -> ()) {
            self.perform = perform
            super.init(frame: .zero)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            nil
        }

        override func viewWillMove(toWindow window: NSWindow?) {
            self.perform(window)
        }
    }
}

extension View {
    public func inspectWindow(_ perform: @escaping (NSWindow?) -> ()) -> some View {
        self.background { WindowInspectorView(perform: perform) }
    }
}

#endif
