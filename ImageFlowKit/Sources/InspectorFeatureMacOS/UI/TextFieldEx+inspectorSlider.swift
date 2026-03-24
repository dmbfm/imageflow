import Design
import Helpers
import Logging
import SwiftUI

extension TextFieldEx {
    func inspectorSlider(
        percentage: CGFloat,
        showSlider: Bool = true,
        horizontalPadding: CGFloat = 0,
        onDrag: ((InspectorTextFieldSliderModifier.DragData) -> ())? = nil
    ) -> some View {
        self.modifier(
            InspectorTextFieldSliderModifier(
                percentage: percentage,
                showSlider: showSlider,
                horizontalPadding: horizontalPadding,
                onDrag: onDrag
            )
        )
    }
}

struct InspectorTextFieldSliderModifier: ViewModifier {
    var percentage: CGFloat = 0.5
    var showSlider: Bool = true
    var horizontalPadding: CGFloat = 0
    var style: Style = .default
    var onDrag: ((DragData) -> ())?
    @State var width: CGFloat = 0
    @State var editable: Bool = false
    @State var hover: Bool = false
    @State var dragState = DragState()
    @FocusState var focused: Bool
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.hoverEffect) var highlightOnHover

    class DragState {
        var initialValue: CGFloat? = nil
    }

    struct DragData {
        var phase: GesturePhase
        var initial: CGFloat
        var current: CGFloat
        var initialPos: CGFloat
        var currentPos: CGFloat
    }

    struct Style {
        var foregroundColor: PlatformColor = Colors.inspectorControlForeground.platformColor
        var sliderColor: Color = DS.textInputSlider.color
        var backgroundColor: Color = DS.textInputBackground.color
        var backgroundColorHighlighted: Color = DS.textInputSliderHighlight.color
        var verticalPadding: CGFloat = 4
        var borderWidth: CGFloat = 1
        var cornerRadiusInner: CGFloat = 6
        var cornerRadiusOuter: CGFloat = 7

        static let `default`: Self = .init()
    }

    var pos: CGFloat {
        if self.showSlider {
            self.percentage.clamped(to: 0...1) * self.width
        } else {
            self.width
        }
    }

    var showHighlight: Bool {
        (self.hover || self.dragState.initialValue != nil)
    }

    var backgroundColor: Color {
        self.showHighlight
            ? self.style.backgroundColorHighlighted
            : self.style.sliderColor
    }

    func body(content: Content) -> some View {
        content
            .textFieldExStyle(.plain)
            .textFieldExForegroudColor(self.style.foregroundColor)
            .textFieldExInteractionMode(.commit)
            .textFieldExIsEditable(self.editable)
            .textFieldExDidEndEditing {
                self.focused = false
                self.editable = false
            }
            .focused(self.$focused)
            .multilineTextAlignment(.center)
            .padding(.vertical, self.style.verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background {
                if self.showSlider {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(self.backgroundColor)
                            .frame(width: self.pos, alignment: .leading)
                        Spacer(minLength: 0)
                    }
                }
            }
            .onGeometryChange(
                for: CGFloat.self,
                of: {
                    $0.size.width
                },
                action: { self.width = $0 }
            )
            .clipShape(RoundedRectangle(cornerRadius: self.style.cornerRadiusInner))
            .padding(self.style.borderWidth)
            .background(self.style.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: self.style.cornerRadiusOuter))
            #if os(macOS)
        .gesture(
            ValueDragGesture { value in
                let current = value.location.x / self.width
                switch value.state {
                case .began:
                    self.dragState.initialValue = self.percentage
                    self.onDrag?(
                        .init(
                            phase: .began,
                            initial: self.percentage,
                            current: self.percentage,
                            initialPos: value.startLocation.x,
                            currentPos: value.location.x
                        )
                    )
                case .changed:
                    if let initialValue = self.dragState.initialValue {
                        self.onDrag?(
                            .init(
                                phase: .changed,
                                initial: initialValue,
                                current: current.roundTo(fractionalDigits: 2),
                                initialPos: value.startLocation.x,
                                currentPos: value.location.x
                            )
                        )
                    }
                case .ended:
                    if let initialValue = self.dragState.initialValue {
                        self.dragState.initialValue = nil
                        self.onDrag?(
                            .init(
                                phase: .ended,
                                initial: initialValue,
                                current: current.roundTo(fractionalDigits: 2),
                                initialPos: value.startLocation.x,
                                currentPos: value.location.x
                            )
                        )
                    }
                case .cancelled, .failed:
                    if let initialValue = self.dragState.initialValue {
                        self.dragState.initialValue = nil
                        self.onDrag?(
                            .init(
                                phase: .cancelled,
                                initial: initialValue,
                                current: current,
                                initialPos: value.startLocation.x,
                                currentPos: value.location.x
                            )
                        )
                    }
                case .possible:
                    break
                @unknown default:
                    self.dragState.initialValue = nil
                }
            }
        )
            #endif
            .onTapGesture {
                if !self.editable {
                    self.editable = true
                    self.focused = true
                }
            }
            #if os(macOS)
        .pointerStyle(.frameResize(position: .leading, directions: .all))
        #endif
        .onHover {
            self.hover = $0
        }
    }
}

#if os(macOS)
private struct ValueDragGesture: NSGestureRecognizerRepresentable {

    var handler: (Value) -> ()
    @State var startLocation: CGPoint = .zero

    struct Value {
        var state: NSGestureRecognizer.State
        var startLocation: CGPoint
        var location: CGPoint
    }

    func makeNSGestureRecognizer(context: Context) -> NSPanGestureRecognizer {
        let gesture = NSPanGestureRecognizer()
        return gesture
    }

    func updateNSGestureRecognizer(_ recognizer: NSPanGestureRecognizer, context: Context) {
    }

    func handleNSGestureRecognizerAction(_ recognizer: NSPanGestureRecognizer, context: Context) {
        log("gesture:\(recognizer.state):\(recognizer.translation(in: nil))")

        if recognizer.state == .began {
            self.startLocation = context.converter.location(in: .local)
        }

        self.handler(
            .init(
                state: recognizer.state,
                startLocation: self.startLocation,
                location: context.converter.location(in: .local)
            )
        )
    }
}

// struct WidthProbeView: NSViewRepresentable {

//     @Binding var width: CGFloat

//     func makeNSView(context: Context) -> Inner {
//         let view = Inner()
//         view.widthBinding = self._width
//         // view.widthBinding = .init(
//         //     get: {
//         //         log("get!")
//         //         return 0.0
//         //     },
//         //     set: { _ in
//         //         log("set!")
//         //     }
//         // )
//         return view
//     }

//     func updateNSView(_ view: Inner, context: Context) {
//         // view.widthBinding = self._width
//     }

//     func sizeThatFits(_ proposal: ProposedViewSize, nsView: Inner, context: Context) -> CGSize? {
//         proposal.replacingUnspecifiedDimensions()
//     }

//     class Inner: NSView {

//         var widthBinding: Binding<CGFloat>?

//         override var frame: NSRect {
//             didSet {
//                 // log("width:???????????")
//                 if self.frame.width != oldValue.width {
//                     Task {
//                         //         log("width:!!!!!!!!!!")
//                         self.widthBinding?.wrappedValue = self.bounds.width
//                     }
//                 }
//             }
//         }

//         override func draw(_ dirtyRect: NSRect) {}
//     }
// }

#endif
