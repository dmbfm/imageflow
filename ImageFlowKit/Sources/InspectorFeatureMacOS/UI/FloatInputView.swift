import Helpers
import InspectorFeatureShared
import Logging
import SwiftUI

/// A flexible numeric input view that accepts keyboard input and mouse dragging. Instead
/// of a `Binding`, this control takes in a `value`, and calls the `onChange` closure whenever
/// the value changes due to user input. The `Change` argument provides
/// additional information, such as a possible `oldValue` and a `commit` flag, that
/// is set only when the change is a "final" value (e.g., a value submited once the
/// user presses the Enter key, or at the end of the drag gesture.) This additional
/// information is important when implementing undo operations.
struct FloatInputView: View {
    /// The current value being shown
    private var value: Double
    /// An optional range. When suppliend, will make the background be drawn as
    /// a slider, and  values dragged with the mouse will be limited to the range. The
    /// range *is not* enforced for numbers the user types-in.
    private var range: ClosedRange<Double>?
    /// An optional step value. Used only when `range` is not nil. When provider, dragged
    /// numbers will only change by the amount defined by `step`. Has no effect on typed-in
    /// numbers
    private var step: Double?
    /// The sensitivity/speed when the user changes  the value by dragging with
    /// the mouse. Used only when `range` is nil.
    private var sensitivity: Sensitivity = .init()
    /// An optional suffix to be appended to the value. Can be used, for
    /// instance, for measurement units.
    private var suffix: String? = nil
    /// Called whennever the value is changed due to user input.
    private var onChange: (Change) -> ()

    @Binding var dragState: DragState
    @State private var startValue: Double = 0

    @Environment(\.floatInputViewNumberFormatter) var formatter

    /// - Parameters:
    ///   - value: The current value being shown
    ///   - range: An optional range. When suppliend, will make the background be drawn as
    /// a slider, and  values dragged with the mouse will be limited to the range. The
    /// range *is not* enforced for numbers the user types-in.
    ///   - sensitivity: The sensitivity/speed when the user changes  the value by dragging with
    /// the mouse. Used only when `range` is nil.
    ///   - suffix: An optional suffix to be appended to the value. Can be used, for
    /// instance, for measurement units.
    ///   - onChange: Called whennever the value is changed due to user input.
    internal init(
        value: Double,
        range: ClosedRange<Double>? = nil,
        step: Double? = nil,
        sensitivity: FloatInputView.Sensitivity = .init(),
        suffix: String? = nil,
        dragState: Binding<DragState> = .constant(.notDragging),
        onChange: @escaping (FloatInputView.Change) -> ()
    ) {
        self.value = value
        self.range = range
        self.step = step
        self.sensitivity = sensitivity
        self.suffix = suffix
        self.onChange = onChange
        self._dragState = dragState
    }

    struct Change {
        var oldValue: Double?
        var newValue: Double
        var shiftDown: Bool = false
        var commit: Bool
    }

    struct Sensitivity {
        var normal: CGFloat = 0.1
        var slow: CGFloat = 0.05 * 0.1
        var high: CGFloat = 1.0
    }

    var textFieldBinding: Binding<Double> {
        .init(
            get: {
                self.value
            },
            set: { newValue in
                if newValue != self.value {
                    self.onChange(.init(newValue: newValue, commit: true))
                }
            }
        )
    }

    var percentage: Double {
        if let range = self.range {
            (self.value - range.lowerBound) / (range.upperBound - range.lowerBound)
        } else {
            self.value
        }
    }

    var textBinding: Binding<String> {
        if let suffix {
            .init(
                get: {
                    (self.formatter.string(for: self.value) ?? "") + suffix
                },
                set: { newValue in
                    if let value = Double(newValue.trimmingSuffix(suffix)) {
                        self.onChange(.init(oldValue: nil, newValue: value, shiftDown: false, commit: true))
                    }
                }
            )
        } else {
            .init(
                get: {
                    (self.formatter.string(for: self.value) ?? "")
                },
                set: { newValue in
                    if let value = Double(newValue) {
                        self.onChange(.init(oldValue: nil, newValue: value, shiftDown: false, commit: true))
                    }
                }
            )
        }
    }

    var body: some View {
        TextFieldEx(text: self.textBinding)
            .inspectorSlider(percentage: self.percentage, showSlider: self.range != nil) { data in

                if let range = self.range {
                    let speed = self.isShiftDown ? 0.1 : 1.0
                    let pos = data.initial + speed * (data.current - data.initial)
                    let newValue = self.step.maybeReduce(
                        (pos * (range.upperBound - range.lowerBound) + range.lowerBound).clamped(
                            to: range
                        )
                    ) { acc, value in
                        acc.snapping(toIncrements: value, epsilon: value)
                    }
                    let oldValue = data.initial * (range.upperBound - range.lowerBound) + range.lowerBound
                    switch data.phase {
                    case .began:
                        self.dragState = .dragging
                        self.onChange(
                            .init(oldValue: oldValue, newValue: newValue, shiftDown: self.isShiftDown, commit: false)
                        )
                    case .changed:
                        self.dragState = .dragging
                        self.onChange(
                            .init(oldValue: oldValue, newValue: newValue, shiftDown: self.isShiftDown, commit: false)
                        )
                    case .ended:
                        self.dragState = .notDragging
                        self.onChange(
                            .init(oldValue: oldValue, newValue: newValue, shiftDown: self.isShiftDown, commit: true)
                        )
                    case .cancelled:
                        self.dragState = .notDragging
                        self.onChange(
                            .init(oldValue: oldValue, newValue: oldValue, shiftDown: self.isShiftDown, commit: false)
                        )
                    }
                } else {
                    let speed =
                        self.isShiftDown
                        ? self.sensitivity.slow : (self.isOptionDown ? self.sensitivity.high : self.sensitivity.normal)
                    let digits = self.isShiftDown ? 2 : 1
                    let newValue = (self.startValue + speed * (data.currentPos - data.initialPos)).roundTo(
                        fractionalDigits: digits
                    )
                    switch data.phase {
                    case .began:
                        self.dragState = .dragging
                        self.startValue = self.value
                    case .changed:
                        self.dragState = .dragging
                        self.onChange(
                            .init(oldValue: nil, newValue: newValue, shiftDown: self.isShiftDown, commit: false)
                        )
                    case .ended:
                        self.dragState = .dragging
                        self.onChange(
                            .init(
                                oldValue: self.startValue,
                                newValue: newValue,
                                shiftDown: self.isShiftDown,
                                commit: true
                            )
                        )
                    case .cancelled:
                        self.onChange(
                            .init(
                                oldValue: self.startValue,
                                newValue: self.startValue,
                                shiftDown: self.isShiftDown,
                                commit: false
                            )
                        )
                    }
                }
            }
    }
}

extension EnvironmentValues {
    @Entry var floatInputViewNumberFormatter: NumberFormatter = formatter
}

extension View {
    func floatInputViewNumberFormatter(_ formatter: NumberFormatter) -> some View {
        self.environment(\.floatInputViewNumberFormatter, formatter)
    }
}

let formatter = {
    let f = NumberFormatter()
    f.locale = .init(identifier: "en-US")
    f.minimumIntegerDigits = 1
    f.minimumFractionDigits = 2
    f.maximumFractionDigits = 1000
    return f
}()

#Preview {
    @Previewable @State var value: Double = 1
    VStack {
        FloatInputView(
            value: value,
            range: 0...10,
            onChange: { change in
                log("change: \(change)")
                value = change.newValue
            }
        )

        FloatInputView(
            value: value,
            range: 0...10,
            onChange: { change in
                log("change: \(change)")
                value = change.newValue
            }
        )
        .hoverEffect(false)

        FloatInputView(
            value: value,
            range: nil,
            onChange: { change in
                log("change: \(change)")
                value = change.newValue
            }
        )
    }
    .padding()
}
