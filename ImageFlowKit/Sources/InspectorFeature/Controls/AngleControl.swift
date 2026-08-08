import Combine
import ComponentKit
import FormatKit
import Helpers
import SettingsFeature
import SharedModels
import Values
import XKit

struct AngleControlConfiguration {
    var range: ClosedRange<Double>?
    var formatter: DoubleFormatConfiguration = .default
}

@MainActor
final class AngleControl: Control<Double, AngleControlConfiguration, NumericControlContext> {

    @PublishedEx var value: Double {
        didSet {
            self.updateValue()
        }
    }

    @PublishedEx var unit: AngleUnit = .degrees {
        didSet {
            self.didSetUnit()
        }
    }

    @PublishedEx var snapEnabled: Bool = false {
        didSet {
            self.didSetSnap()
        }
    }

    var context: NumericControlContext

    var configuration: AngleControlConfiguration {
        didSet {
            self.floatControlView.configuration = .init(
                drag: self.dragConfiguration,
                formatter: self.configuration.formatter
            )
        }
    }

    var onChange: ((Change<Double>) -> ())?

    var transformedDoubleValue: Double {
        self.value.fromRadians(to: self.unit)
    }

    var selectedUnitItemIndex: Int {
        switch self.unit {
        case .degrees: 0
        case .radians: 1
        }
    }

    var transformedRange: ClosedRange<Double> {

        let range: ClosedRange<Double> = self.configuration.range ?? -.pi...(.pi)

        switch self.unit {
        case .degrees:
            let lower = range.lowerBound.fromRadians(to: .degrees).roundTo(fractionalDigits: 6)
            let upper = range.upperBound.fromRadians(to: .degrees).roundTo(fractionalDigits: 6)
            return lower...upper
        case .radians:
            return range
        }
    }

    var dragConfiguration: NumberInput.DragConfiguration {
        .range(
            .closed(
                .init(
                    range: self.transformedRange,
                    sensitivity: .init(),
                    snap: .init(
                        increments: 15,
                        epsilon: 15,
                        alwaysEnabled: self.snapEnabled,
                        modifier: .command
                    ),
                    fractionalDigits: self.unit == .degrees ? 1 : 2
                )
            )
        )
    }

    var view: XView {
        self.stackView
    }

    var auxiliaryView: XView? {
        self.auxStackView
    }

    lazy var floatControlView: FloatControlView = {
        FloatControlView(
            self.transformedDoubleValue,
            configuration: .init(drag: self.dragConfiguration, formatter: self.configuration.formatter)
        )
        .with(
            \.onChange,
            { [weak self] change in
                guard let self else { return }
                self.onChange?(
                    .init(
                        newValue: change.newValue.toRadians(from: self.unit),
                        oldValue: change.oldValue.map({ $0.toRadians(from: self.unit) }),
                        commit: change.commit,
                    )
                )
            }
        )
    }()

    lazy var dialView: AngleDial = {
        AngleDial(
            angle: self.value,
            range: self.configuration.range,
            style: .default
                .with(\.fillColor, .init(XColor.system.quaternaryFill))
                .with(\.flushToLeadingEdge, true)
        )
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
        .constrainingSize(toConstant: .init(width: 28, height: 28))
    }()

    lazy var stackView: HStack = {
        HStack(views: [
            self.dialView,
            self.floatControlView,
        ])
    }()

    lazy var unitsPickerView: Picker = {
        Picker(
            [
                AngleUnit.degrees.shortLabel,
                AngleUnit.radians.shortLabel,
            ],
            selected: self.selectedUnitItemIndex,
            onChange: { [weak self] index in self?.unit = index == 0 ? .degrees : .radians }
        )
        .rx(self.$unit.map({ $0 == .degrees ? 0 : 1 }), kp: \.selected)
        .with(\.style, .plain)
        .with(\.font, .preferredFont(forTextStyle: .caption1))
        .with(\.tint, .system.secondaryLabel)
    }()

    lazy var snapButtonView: Button = {
        Button(
            "",
            systemSymbolName: "lines.measurement.horizontal",
            buttonSize: .mini,
        ) { [weak self] in self?.snapEnabled.toggle() }
        .with(\.imagePosition, .imageOnly)
        .withRef({ $0.setButtonType(.onOff) })
        .rx(self.$snapEnabled.map({ $0 ? .on : .off }), kp: \.state)
    }()

    lazy var auxStackView: HStack = {
        HStack(views: [
            self.unitsPickerView,
            self.snapButtonView,
        ])
    }()

    var cancellables: Set<AnyCancellable> = []

    init(_ value: Value, configuration: Configuration = .init(range: nil), context: NumericControlContext) {
        self.value = value
        self.configuration = configuration
        self.context = context

        self.floatControlView.numberInput.$isDragging.sink { [weak self] isDragging in
            self?.context.statusBarMessage(isDragging ? .statusMessageNumberSnapDrag : nil)
        }.store(in: &self.cancellables)
    }

    func setDisabled(_ disabled: Bool) {
        self.floatControlView.setDisabled(disabled)
    }

    func didSetUnit() {
        self.updateConfiguration()
        self.updateValue()
    }

    func didSetSnap() {
        self.updateConfiguration()
    }

    func updateConfiguration() {
        self.floatControlView.configuration = .init(drag: self.dragConfiguration)
    }

    func updateValue() {
        if self.floatControlView.value != self.transformedDoubleValue {
            self.floatControlView.value = self.transformedDoubleValue
        }
        if self.dialView.angle != -self.value {
            self.dialView.angle = -self.value
        }
    }
}
