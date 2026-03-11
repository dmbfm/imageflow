import Helpers
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
    /// The sensitivity/speed when the user changes  the value by dragging with
    /// the mouse. Used only when `range` is nil.
    private var sensitivity: Sensitivity = .init()
    /// An optional suffix to be appended to the value. Can be used, for
    /// instance, for measurement units.
    private var suffix: String? = nil
    /// Called whennever the value is changed due to user input.
    private var onChange: (Change) -> ()

    @State private var startValue: Double = 0

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
        sensitivity: FloatInputView.Sensitivity = .init(),
        suffix: String? = nil,
        onChange: @escaping (FloatInputView.Change) -> ()
    ) {
        self.value = value
        self.range = range
        self.sensitivity = sensitivity
        self.suffix = suffix
        self.onChange = onChange
    }

    struct Change {
        var oldValue: Double?
        var newValue: Double
        var commit: Bool
    }

    struct Sensitivity {
        var normal: CGFloat = 0.1
        var slow: CGFloat = 0.05 * 0.1
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

    var body: some View {
        TextFieldEx(
            value: self.textFieldBinding,
            format: .number.locale(.init(identifier: "en-US")).precision(.significantDigits(3...10)),
            suffix: self.suffix,
        )
        .inspectorSlider(percentage: self.percentage, showSlider: self.range != nil) { data in
            if let range = self.range {
                let newValue = (data.current * (range.upperBound - range.lowerBound) + range.lowerBound).clamped(
                    to: range
                )
                let oldValue = data.initial * (range.upperBound - range.lowerBound) + range.lowerBound
                switch data.phase {
                case .began:
                    self.onChange(.init(oldValue: oldValue, newValue: newValue, commit: false))
                case .changed:
                    self.onChange(.init(oldValue: oldValue, newValue: newValue, commit: false))
                case .ended:
                    self.onChange(.init(oldValue: oldValue, newValue: newValue, commit: true))
                case .cancelled:
                    self.onChange(.init(oldValue: oldValue, newValue: oldValue, commit: false))
                }
            } else {
                let speed = self.isShiftDown ? self.sensitivity.slow : self.sensitivity.normal
                let digits = self.isShiftDown ? 2 : 1
                let newValue = (self.startValue + speed * (data.currentPos - data.initialPos)).roundTo(
                    fractionalDigits: digits
                )
                switch data.phase {
                case .began:
                    self.startValue = self.value
                case .changed:
                    self.onChange(.init(oldValue: nil, newValue: newValue, commit: false))
                case .ended:
                    self.onChange(.init(oldValue: self.startValue, newValue: newValue, commit: true))
                case .cancelled:
                    self.onChange(.init(oldValue: self.startValue, newValue: self.startValue, commit: false))
                }
            }
        }
    }
}

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
