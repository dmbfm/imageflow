import CommonUtils
import Design
import Logging
import SwiftUI

public struct GridView: View, @preconcurrency Equatable {
    public static func == (lhs: GridView, rhs: GridView) -> Bool {
        true
    }

    let configuration: CanvasConfiguration
    @Binding var viewport: CanvasViewport
    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) var colorScheme
    @State var circleImageDrawer = CircleImageDrawer()

    public init(viewport: Binding<CanvasViewport>, configuration: CanvasConfiguration = .default) {
        self._viewport = viewport
        self.configuration = configuration
    }

    func draw(_ context: inout GraphicsContext, _ size: CGSize) {
        context.withCGContext { cgContext in
            let imageSize: CGFloat = 40 / self.displayScale
            let size = self.viewport.convert(imageSize, from: .canvas, to: .screen)
            let offsetX = -viewport.origin.x.truncatingRemainder(dividingBy: imageSize)
            let offsetY = -viewport.origin.y.truncatingRemainder(dividingBy: imageSize)
            let offset = viewport.convert(CGSize(width: offsetX, height: offsetY), from: .canvas, to: .screen)

            let image = self.circleImageDrawer.draw(Colors.canvasBackground.cgColor, Colors.canvasBackgroundDot.cgColor)

            cgContext.draw(
                image,
                in: .init(
                    origin: .init(x: offset.width, y: offset.height),
                    size: .init(width: size, height: size)
                ),
                byTiling: true
            )
        }
    }

    public var body: some View {
        Canvas(opaque: true, rendersAsynchronously: true, renderer: self.draw(_:_:))
            #if os(macOS)
                .overlay {
                    GestureOverlayView() { translation in
                        self.viewport.translate(by: -translation.cgSize, in: .screen)
                    } onScroll: { location, amount in
                        let newZoom =
                            switch amount {
                            case .precise(let delta):
                                self.viewport.scale - delta
                            case .regular(let delta):
                                self.viewport.scale - self.configuration.scrollWheelSensitivity * delta
                            }

                        self.viewport.zoom(self.configuration.clampZoom(newZoom), atScreenPoint: location)
                    }
                }
            #else
                .gesture(
                    MultifingerDragGesture(numberOfTouches: 2) { translation in
                        self.viewport.translate(by: -translation.cgSize, in: .screen)
                    }
                )
                .modifier(ZoomGestureModifier(viewport: self.$viewport, configuration: self.configuration))
            #endif
    }
}

// MARK: - iOS specific

#if os(iOS)
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

// MARK: - macOS specific

#if os(macOS)
    private struct GestureOverlayView: NSViewRepresentable {

        var onDrag: (CGPoint) -> ()
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

        class Inner: NSView {
            var onDrag: ((CGPoint) -> ())?
            var onScroll: ((CGPoint, ScrollAmount) -> ())?

            override var isFlipped: Bool {
                true
            }

            override init(frame frameRect: NSRect) {
                super.init(frame: frameRect)
                let panGesture = NSPanGestureRecognizer(
                    target: self,
                    action: #selector(panGestureHandler(_:))
                )
                panGesture.buttonMask = 0x04
                self.addGestureRecognizer(panGesture)
            }

            required init?(coder: NSCoder) {
                nil
            }

            @objc
            func panGestureHandler(_ gesture: NSPanGestureRecognizer) {
                let t = gesture.translation(in: nil)
                self.onDrag?(.init(x: t.x, y: -t.y))
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

#if os(iOS)
#endif

#Preview {
    @Previewable @State var viewport: CanvasViewport = .init()

    GridView(viewport: $viewport)
        .border(.gray)
        .padding(20)
        .frame(width: 800, height: 600)
}
