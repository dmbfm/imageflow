#if os(iOS)

import Helpers
import InspectorFeatureShared
import Logging
import SharedModels
import SwiftUI

struct DraggableFloatInput: View {
    let value: Double
    var sensitivity: Double = 0.1
    var fractionalDigits: Int? = 2
    var onChange: (Change) -> ()

    @State var initialValue: Double = 0.0
    @State var initialDragValue: Double? = nil

    @Environment(\.draggableFloatInputLeadingSpacing) var spacing
    @Environment(\.draggableFloatInputSnapping) var snapping
    @Environment(\.draggableFloatInputFormatter) var formatter
    @Environment(\.isEnabled) var enabled

    struct Snapping {
        var increment: Double
        var tolerance: Double
    }

    init(value: Double, sensitivity: Double = 0.1, fractionalDigits: Int? = 2, onChange: @escaping (Change) -> Void) {
        self.value = value
        self.sensitivity = sensitivity
        self.onChange = onChange
        self.fractionalDigits = fractionalDigits
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

    func newDraggedValue(initial: Double, translation: Double) -> Double {
        self.snapping
            .maybeReduce(
                self.truncatingToFractionalDigits(initial + self.sensitivity * translation)
            ) { acc, curr in
                acc.snapping(toIncrements: curr.increment, epsilon: curr.tolerance)
            }
    }

    func onDragChanged(_ translation: CGSize) {
        if self.initialDragValue == nil {
            self.initialDragValue = self.value
        }

        if let initial = self.initialDragValue {
            let newValue = newDraggedValue(initial: initial, translation: translation.width)
            self.onChange(.init(value: newValue, previous: initial, commit: false))
        }
    }

    func onDragEnded(_ translation: CGSize) {
        if let initial = self.initialDragValue {
            let newValue = newDraggedValue(initial: initial, translation: translation.width)
            self.onChange(.init(value: newValue, previous: initial, commit: true))
        }
        self.initialDragValue = nil
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
            DragGesture()
                .onChanged({ value in self.onDragChanged(value.translation) })
                .onEnded({ value in self.onDragEnded(value.translation) })
        )
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
