import Combine
import ComponentKit
import Helpers
import SharedModels
import Values
import XKit

struct MinMaxSliderArrayControlConfiguration {
    var range: ClosedRange<Double> = 0...1
    var formatter: FloatingPointFormatStyle<Double> = .number.precision(.fractionLength(2))
    var labels: [String] = [
        "Red",
        "Green",
        "Blue",
        "Alpha",
    ]
}

@MainActor
final class MinMaxSliderArrayControl: Control<[MinMax], MinMaxSliderArrayControlConfiguration, ()> {
    @PublishedEx var value: [ComponentKit.MinMax] = [] {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var configuration: MinMaxSliderArrayControlConfiguration

    var context: ()

    var view: XKit.XView {
        self.inner
    }

    lazy var inner: MinMaxLabeledSliderArray = {
        MinMaxLabeledSliderArray(
            self.value,
            range: self.configuration.range,
            formatter: self.configuration.formatter
        )
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
        .with(
            \.onChange,
            { [weak self] index, change in
                guard let self else { return }
                let oldValue = self.value
                self.value[index] = change.newValue
                self.onChange?(
                    .init(
                        newValue: self.value,
                        oldValue: oldValue,
                        commit: change.commit
                    )
                )
            }
        )
        .with(
            \.labelForRow,
            { index in
                self.configuration.labels[tryGetAt: index] ?? ""
            }
        )
    }()

    var onChange: ((Change<[ComponentKit.MinMax]>) -> ())?

    init(
        value: [MinMax] = [],
        configuration: MinMaxSliderArrayControlConfiguration = .init()
    ) {
        self.value = value
        self.configuration = configuration
    }

    func setDisabled(_ disabled: Bool) {
        logger.error("TODO: setDisabled")
    }

    func update() {
        self.inner.values = self.value
    }
}
