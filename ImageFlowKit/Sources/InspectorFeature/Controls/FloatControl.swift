import Combine
import ComponentKit
import Helpers
import Values
import XKit

struct FloatControlConfiguration {
    var drag: NumberInput.DragConfiguration
}

@MainActor
final class FloatControl: Control<Double, FloatControlConfiguration, ()> {

    @PublishedEx var value: Double {
        didSet {
            if self.inner.value != self.value {
                self.inner.value = self.value
            }
        }
    }

    var context: ()

    var configuration: FloatControlConfiguration = .init(drag: .free(.init(fractionalDigits: 2))) {
        didSet {
            self.inner.configuration = self.configuration
        }
    }

    var view: XView {
        self.inner
    }

    lazy var inner: FloatControlView = {
        FloatControlView(self.value, configuration: self.configuration)
            .with(
                \.onChange,
                { [weak self] change in
                    self?.onChange?(change)
                }
            )
    }()

    var onChange: ((Change<Double>) -> ())?

    func setDisabled(_ disabled: Bool) {
        self.inner.setDisabled(disabled)
    }

    init(_ value: Double, configuration: Configuration) {
        self.value = value
        self.configuration = configuration
    }
}

final class FloatControlView: XView, WithRef {
    @PublishedEx var value: Double {
        didSet {
            if self.numberInput.value != self.value {
                self.numberInput.value = self.value
            }
        }
    }

    var configuration: FloatControlConfiguration {
        didSet {
            self.numberInput.dragConfiguration = self.configuration.drag
        }
    }

    var onChange: ((Change<Double>) -> ())?

    lazy var numberInput: NumberInput = {
        NumberInput(
            value,
            formatter: .number.precision(.fractionLength(2)),
            style: .default
        )
        .onChange { [weak self] change in
            self?.value = change.newValue
            self?.onChange?(
                .init(
                    newValue: change.newValue,
                    oldValue: change.oldValue,
                    commit: change.commit
                )
            )
        }
        .with(\.dragConfiguration, self.configuration.drag)
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    init(
        _ value: Double,
        configuration: FloatControlConfiguration = .init(drag: .free(.init(fractionalDigits: 2)))
    ) {
        self.value = value
        self.configuration = configuration

        super.init(frame: .zero)

        self.addSubview(self.numberInput)
        self.numberInput.constraintToFill(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDisabled(_ disabled: Bool) {
        self.numberInput.isEnabled = !disabled
    }

}
