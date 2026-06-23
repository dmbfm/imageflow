import Combine
import ComponentKit
import Helpers
import SharedModels
import Values
import XKit

struct IntControlConfiguration {
    var range: Range = .none

    enum Range {
        case closed(ClosedRange<Int>)
        case minValue(Int)
        case none
    }
}

@MainActor
final class IntControl: Control<Int, IntControlConfiguration, ()> {

    @PublishedEx var value: Int {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var configuration: IntControlConfiguration = .init() {
        didSet {
            self.numberInput.dragConfiguration = self.dragConfiguration
        }
    }

    var context: ()

    var view: XKit.XView {
        self.numberInput
    }

    var onChange: ((Change<Int>) -> ())?

    var dragConfiguration: NumberInput.DragConfiguration {
        switch self.configuration.range {
        case .closed(let range):
            return .range(
                .closed(
                    .init(
                        range: .init(uncheckedBounds: (Double(range.lowerBound), Double(range.upperBound))),
                        sensitivity: .init(slow: 0.1, modifier: .shift),
                        snap: .init(increments: 1.0),
                        fractionalDigits: 0
                    )
                )
            )
        case .minValue(let minValue):
            return .range(
                .partialFrom(
                    .init(
                        lowerBound: Double(minValue),
                        sensitivity: .init(shiftDown: 0.1),
                        fractionalDigits: 0
                    )
                )
            )
        case .none:
            return .free(
                .init(
                    sensitivity: .init(shiftDown: 0.1),
                    fractionalDigits: 0
                )
            )
        }
    }

    lazy var numberInput: NumberInput = {
        NumberInput(
            Double(self.value),
            formatter: .number.precision(.fractionLength(0)),
            style: .default
        )
        .onChange { [weak self] change in
            guard let self else { return }
            self.value = Int(change.newValue)
            self.onChange?(
                .init(
                    newValue: Int(change.newValue),
                    oldValue: Int(change.oldValue),
                    commit: change.commit
                )
            )
        }
        .with(\.dragConfiguration, self.dragConfiguration)
        .with(\.stepperConfiguration, .init(step: 1.0, size: .small))
    }()

    init(_ value: Int) {
        self.value = value
    }

    func setDisabled(_ disabled: Bool) {
        self.numberInput.isEnabled = !disabled
    }

    func update() {
        self.numberInput.value = Double(self.value)
    }
}
