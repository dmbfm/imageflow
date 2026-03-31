#if os(iOS)

import Helpers
import InspectorFeatureShared
import Logging
import SharedModels
import SwiftUI
import UIKit

struct DraggableFloatInput: View {
    let value: Double
    var sensitivity: Sensitivity = .init()
    var fractionalDigits: Int? = 2
    var onChange: (Change) -> ()

    @State var initialValue: Double = 0.0
    @State var initialDragValue: Double? = nil
    @Binding var dragState: DragState

    @Environment(\.draggableFloatInputLeadingSpacing) var spacing
    @Environment(\.draggableFloatInputSnapping) var snapping
    @Environment(\.draggableFloatInputFormatter) var formatter
    @Environment(\.isEnabled) var enabled

    struct Snapping {
        var enabled: Bool
        var increment: Double
        var tolerance: Double
    }
    
    struct Sensitivity {
        var normal: Double = 0.1
        var slow: Double = 0.025
        var fast: Double = 10.0
    }

    init(value: Double, sensitivity: Sensitivity = .init(), fractionalDigits: Int? = 2, dragState: Binding<DragState> = .constant(.notDragging), onChange: @escaping (Change) -> Void) {
        self.value = value
        self.sensitivity = sensitivity
        self.onChange = onChange
        self.fractionalDigits = fractionalDigits
        self._dragState = dragState
    }

    struct Change {
        var value: Double
        var previous: Double?
        var commit: Bool
    }

    func truncatingToFractionalDigits(_ value: Double) -> Double {
        if let fractionalDigits = self.fractionalDigits {
            value.truncateTo(fractionalDigits: fractionalDigits)
        } else {
            value
        }
    }

    func newDraggedValue(initial: Double, value: TextFieldExDragGestureHandler.Value) -> Double {
        let translation = value.translation
        let shiftDown = value.shiftDown
        let commandDown = value.commandDown
        let optionDown = value.optionDown
        
        let sensitivity: Double = shiftDown ? self.sensitivity.slow : (optionDown ? self.sensitivity.fast : self.sensitivity.normal)
        
        return self.snapping
            .maybeReduce(
                self.truncatingToFractionalDigits(initial + sensitivity * translation.width)
            ) { acc, curr in
                if curr.enabled || commandDown {
                    acc.snapping(toIncrements: curr.increment, epsilon: curr.tolerance)
                } else {
                    acc
                }
            }
    }

    func onDragChanged(_ value: TextFieldExDragGestureHandler.Value) {
        if self.initialDragValue == nil {
            self.initialDragValue = self.value
            self.dragState = .dragging
        }

        if let initial = self.initialDragValue {
            let newValue = newDraggedValue(initial: initial,  value: value)
            self.onChange(.init(value: newValue, previous: initial, commit: false))
        }
    }

    func onDragEnded(_ value: TextFieldExDragGestureHandler.Value) {
        if let initial = self.initialDragValue {
            let newValue = newDraggedValue(initial: initial, value: value)
            self.onChange(.init(value: newValue, previous: initial, commit: true))
        }
        self.initialDragValue = nil
        self.dragState = .notDragging
    }

    var body: some View {
        HStack {
            Spacer(minLength: spacing)
            TextFieldEx(
                text: .init(
                    get: {
                        formatter.string(for: self.value) ?? ""
                    },
                    set: { _ in
                    }
                )
            )
            .textFieldExKeyboardType(.numbersAndPunctuation)
            .textFieldExStyle(.inspectorDefault)
            .textFieldExForegroundColor(self.enabled ? nil : .secondaryLabel)
            .textFieldExDidBeginEditing { _ in
                self.initialValue = self.value
            }
            .textFieldExDidChange { _ in
            }
            .textFieldExDidEndEditing { text in
                if let number = Double(text) {
                    self.onChange(.init(value: number, previous: self.initialValue, commit: true))
                }
            }
            .textFieldExDragGestureHandler(
                .init(onChange: { self.onDragChanged($0) }, onEnded: { self.onDragEnded($0) })
            )
        }
        .background {
            Color.clear
                .contentShape(Rectangle())
        }
        .gesture(
            CustomDragGesture(onChange: { self.onDragChanged($0)}, onEnded: { self.onDragEnded($0)})
        )
    }
}

struct CustomDragGesture: UIGestureRecognizerRepresentable {
    
    typealias Value = TextFieldExDragGestureHandler.Value
    
    var onChange: (Value) -> ()
    var onEnded: (Value) -> ()
    
    @State var startLocation: CGPoint? = nil
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        return gesture
    }
    
    func handleUIGestureRecognizerAction(_ gesture: UIPanGestureRecognizer, context: Context) {
        let shiftDown = gesture.modifierFlags.contains(.shift)
        let optionDown = gesture.modifierFlags.contains(.alternate)
        let commandDown = gesture.modifierFlags.contains(.command)
        let translation = gesture.translation(in: nil).cgSize
        let value = TextFieldExDragGestureHandler.Value(
            translation: translation, shiftDown: shiftDown, commandDown: commandDown, optionDown: optionDown
        )
        switch gesture.state {
        case .began, .changed: self.onChange(value)
        case .ended, .cancelled: self.onEnded(value)
        default: break
        }
    }
}

extension EnvironmentValues {
    @Entry var draggableFloatInputLeadingSpacing: CGFloat = 0.0
    @Entry var draggableFloatInputSnapping: DraggableFloatInput.Snapping? = nil
    @Entry var draggableFloatInputFormatter: NumberFormatter = formatter
}

extension View {
    func draggableFloatInputLeadingSpacing(_ value: CGFloat) -> some View {
        self.environment(\.draggableFloatInputLeadingSpacing, value)
    }

    func draggableFloatInputSnapping(_ snapping: DraggableFloatInput.Snapping?) -> some View {
        self.environment(\.draggableFloatInputSnapping, snapping)
    }

    func draggableFloatInputFormatter(_ formatter: NumberFormatter) -> some View {
        self.environment(\.draggableFloatInputFormatter, formatter)
    }
}

#endif
