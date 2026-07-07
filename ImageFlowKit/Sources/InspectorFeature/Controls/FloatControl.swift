import Combine
import ComponentKit
import Helpers
import SharedModels
import Values
import XKit

struct FloatControlConfiguration {
    var drag: NumberInput.DragConfiguration
    var formatter: FloatingPointFormatStyle = .default
}

struct NumericControlContext {
    var statusBarMessage: (String?) -> ()
    static var `default`: Self { .init(statusBarMessage: { _ in }) }
}

@MainActor
final class FloatControl: Control<Double, FloatControlConfiguration, NumericControlContext> {

    @PublishedEx var value: Double {
        didSet {
            if self.inner.value != self.value {
                self.inner.value = self.value
            }
        }
    }

    var context: NumericControlContext

    var configuration: FloatControlConfiguration = .init(drag: .free(.init(fractionalDigits: 2))) {
        didSet {
            self.inner.configuration = self.configuration
        }
    }

    var view: XView {
        self.inner
    }

    lazy var inner: FloatControlView = {
        FloatControlView(
            self.value,
            configuration: self.configuration
        )
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

    var cancellables: Set<AnyCancellable> = []

    init(_ value: Double, configuration: Configuration, context: NumericControlContext) {
        self.value = value
        self.configuration = configuration
        self.context = context

        self.inner.numberInput.$isDragging.sink { [weak self] isDragging in
            guard let self else { return }
            let message: String =
                switch self.configuration.drag {
                case .range(.closed(_)): .statusMessageNumberRangeDrag
                default: .statusMessageNumberDrag
                }

            self.context.statusBarMessage(isDragging ? message : nil)
        }.store(in: &self.cancellables)
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
            self.numberInput.formatter = self.configuration.formatter
        }
    }

    var onChange: ((Change<Double>) -> ())?

    lazy var numberInput: NumberInput = {
        NumberInput(
            value,
            formatter: self.configuration.formatter,
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
        .withContentHuggingPriority(.defaultLow - 10, for: .horizontal)
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
