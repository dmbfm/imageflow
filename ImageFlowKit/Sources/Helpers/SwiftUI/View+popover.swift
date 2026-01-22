#if os(macOS)

import SwiftUI

public extension View {
    func popover<Content: View>(
        isPresentedAt: Binding<CGPoint?>,
        positioning: PopoverPositioning = .point,
        size: CGSize,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            PopoverPresenterModifier(
                positioning: positioning,
                isPresented: isPresentedAt,
                size: size,
                popoverContent: content
            )
        )
    }
}

public enum PopoverPositioning {
    case point
    case cursor
}

struct PopoverPresenterModifier<PopoverContent: View>: ViewModifier {
    @Binding var isPresented: CGPoint?
    let positioning: PopoverPositioning
    let popoverContent: () -> PopoverContent
    let size: CGSize

    init(
        positioning: PopoverPositioning,
        isPresented: Binding<CGPoint?>,
        size: CGSize,
        popoverContent: @escaping () -> PopoverContent
    ) {
        self.positioning = positioning
        self._isPresented = isPresented
        self.popoverContent = popoverContent
        self.size = size
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                PopoverPresenterView(
                    content: self.popoverContent,
                    size: self.size,
                    positioning: self.positioning,
                    isPresented: self.$isPresented
                )
            }
    }
}

struct PopoverPresenterView<Content: View>: NSViewRepresentable {
    let content: () -> Content
    let size: CGSize
    let positioning: PopoverPositioning
    @Binding var isPresented: CGPoint?

    func makeNSView(context: Context) -> Inner {
        Inner(size: self.size, isPresented: self.$isPresented, positioning: self.positioning, content: self.content)
    }

    func updateNSView(_ view: Inner, context: Context) {
        if let point = self.isPresented {
            if !view.popover.isShown {
                view.show(locationInWindow: point)
            }
        } else {
            if view.popover.isShown {
                Task { @MainActor in
                    view.popover.close()
                }
            }
        }

        view.positioning = self.positioning
    }

    class Inner: NSView, NSPopoverDelegate {

        @Binding var isPresented: CGPoint?
        var positioning: PopoverPositioning

        init(
            size: CGSize,
            isPresented: Binding<CGPoint?>,
            positioning: PopoverPositioning,
            content: @escaping () -> Content
        ) {
            self.content = content
            self._isPresented = isPresented
            self.size = size
            self.positioning = positioning
            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) {
            nil
        }

        let content: () -> Content
        let size: CGSize

        lazy var popover: NSPopover = {
            let p = NSPopover()
            let controller = NSHostingController(rootView: self.content())
            controller.sizingOptions = .standardBounds
            controller.sceneBridgingOptions = []
            p.contentViewController = controller
            p.behavior = .transient
            p.contentSize = size
            p.animates = false
            p.delegate = self
            return p
        }()

        func show(locationInWindow: CGPoint) {
            let locationInWindow =
                switch self.positioning {
                case .point: locationInWindow
                case .cursor: self.window?.mouseLocationOutsideOfEventStream ?? .zero
                }

            let location = self.convert(locationInWindow, from: nil)

            let rect = CGRect(x: location.x, y: location.y, width: 1, height: 1)
            self.popover.show(relativeTo: rect, of: self, preferredEdge: .minY)
            self.isPresented = locationInWindow
        }

        func popoverDidClose(_ notification: Notification) {
            if self.isPresented != nil {
                self.isPresented = nil
            }
        }

        override func hitTest(_ point: NSPoint) -> NSView? {
            nil
        }
    }
}

#endif
