import CommonUtils
import SwiftUI

extension View {
    func canvasGestures(_ viewport: Binding<CanvasViewport>, configuration: CanvasConfiguration) -> some View {
        self.modifier(CanvasGestureModifier(viewport: viewport, configuration: configuration))
    }
}

extension EnvironmentValues {
    @Entry public var canvasNotificationHandler: ((CanvasNotification) -> ())? = nil
}

extension View {
    public func onCanvasViewNotification(_ handler: @escaping (CanvasNotification) -> ()) -> some View {
        self.environment(\.canvasNotificationHandler, handler)
    }
}

public enum CanvasNotification {
    case continuousTranslationBegan
    case continuousTranslationEnded
    case willScrollZoom
    case didScrollZoom
}

// MARK: - macOS

#if os(macOS)
struct CanvasGestureModifier: ViewModifier {
    @Binding var viewport: CanvasViewport
    let configuration: CanvasConfiguration

    @Environment(\.canvasNotificationHandler) var sendNotification
    @Environment(\.undoManager) var undoManager

    func body(content: Content) -> some View {
        content.overlay {
            GestureOverlayView() { translation, state in
                if state == .began {
                    self.sendNotification?(.continuousTranslationBegan)
                }
                self.viewport.translate(by: -translation.cgSize, in: .screen)
                if state == .ended {
                    self.sendNotification?(.continuousTranslationEnded)
                    //     self.undoManager?.endUndoGrouping()
                }
            } onScroll: { location, amount in
                let newZoom =
                    switch amount {
                    case .precise(let delta):
                        self.viewport.scale - delta
                    case .regular(let delta):
                        self.viewport.scale - self.configuration.scrollWheelSensitivity * delta
                    }

                self.sendNotification?(.willScrollZoom)
                self.viewport.zoom(self.configuration.clampZoom(newZoom), atScreenPoint: location)
                self.sendNotification?(.didScrollZoom)
            }
        }
    }
}

struct GestureOverlayView: NSViewRepresentable {

    var onDrag: (CGPoint, NSGestureRecognizer.State) -> ()
    var onScroll: (CGPoint, ScrollAmount) -> ()

    enum ScrollAmount {
        case precise(CGFloat)
        case regular(CGFloat)
    }

    func makeNSView(context: Context) -> Inner {
        let view = Inner()
        view.onDrag = self.onDrag
        view.onScroll = self.onScroll
        return view
    }

    func updateNSView(_ view: Inner, context: Context) {

    }

    class Inner: NSView, NSGestureRecognizerDelegate {
        var onDrag: ((CGPoint, NSGestureRecognizer.State) -> ())?
        var onScroll: ((CGPoint, ScrollAmount) -> ())?

        override var isFlipped: Bool {
            true
        }

        override func hitTest(_ point: NSPoint) -> NSView? {
            let passthrousEvents: [NSEvent.EventType] = [
                .leftMouseDown,
                .leftMouseDragged,
                .leftMouseUp,
                .rightMouseDown,
                .rightMouseDragged,
                .rightMouseUp,
            ]
            if let event = NSApp.currentEvent, passthrousEvents.contains(event.type) {
                return nil
            } else {
                return self
            }
        }

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            let panGesture = NSPanGestureRecognizer(
                target: self,
                action: #selector(panGestureHandler(_:))
            )
            panGesture.buttonMask = 0x04
            panGesture.delegate = self
            self.addGestureRecognizer(panGesture)
        }

        func gestureRecognizer(
            _ gestureRecognizer: NSGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSGestureRecognizer
        ) -> Bool {
            true
        }

        required init?(coder: NSCoder) {
            nil
        }

        @objc
        func panGestureHandler(_ gesture: NSPanGestureRecognizer) {
            let t = gesture.translation(in: nil)
            self.onDrag?(.init(x: t.x, y: -t.y), gesture.state)
            gesture.setTranslation(.zero, in: nil)
        }

        override func scrollWheel(with event: NSEvent) {
            if let onScroll = self.onScroll, event.subtype == .mouseEvent {
                let location = self.convert(event.locationInWindow, from: nil)
                let amount: ScrollAmount =
                    if event.hasPreciseScrollingDeltas {
                        .precise(event.scrollingDeltaY)
                    } else {
                        .regular(event.deltaY)
                    }

                onScroll(location, amount)
            }
        }
    }
}
#endif

// MARK: - iOS

#if os(iOS)
struct CanvasGestureModifier: ViewModifier {
    @Binding var viewport: CanvasViewport
    let configuration: CanvasConfiguration

    func body(content: Content) -> some View {
        content
            .gesture(
                MultifingerDragGesture(numberOfTouches: 2) { translation in
                    self.viewport.translate(by: -translation.cgSize, in: .screen)
                }
            )
            .modifier(ZoomGestureModifier(viewport: self.$viewport, configuration: self.configuration))
    }
}

struct ZoomGestureModifier: ViewModifier {

    @Binding var viewport: CanvasViewport
    @State var zoomAtStart: CGFloat?
    let configuration: CanvasConfiguration

    func body(content: Content) -> some View {
        content
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        if self.zoomAtStart == nil {
                            self.zoomAtStart = viewport.scale
                        }

                        let newZoom = self.zoomAtStart! * value.magnification
                        self.viewport.zoom(configuration.clampZoom(newZoom), atScreenPoint: value.startLocation)
                    }
                    .onEnded { value in
                        let newZoom = self.zoomAtStart! * value.magnification
                        self.viewport.zoom(configuration.clampZoom(newZoom), atScreenPoint: value.startLocation)
                        self.zoomAtStart = nil
                    }
            )
    }
}

struct MultifingerDragGesture: UIGestureRecognizerRepresentable {
    var numberOfTouches: Int = 2
    var action: (CGPoint) -> ()

    init(numberOfTouches: Int = 2, action: @escaping (CGPoint) -> ()) {
        self.action = action
        self.numberOfTouches = numberOfTouches
    }

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        gesture.minimumNumberOfTouches = numberOfTouches
        gesture.maximumNumberOfTouches = numberOfTouches
        gesture.delegate = context.coordinator
        return gesture
    }

    func handleUIGestureRecognizerAction(_ gesture: UIPanGestureRecognizer, context: Context) {
        self.action(gesture.translation(in: nil))
        gesture.setTranslation(.zero, in: nil)
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }
}
#endif
