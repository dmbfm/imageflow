import Combine
import ComponentKit
import Helpers
import Values
import XKit

@MainActor
final class NodeInputControl: Rx, WithRef {

    typealias InnerView = PropertyControlView<
        Values::Value,
        NodeInputControlConfiguration,
        NodeInputControlContext,
        AnyNodeInputValueControl
    >

    public private(set) var view: InnerView

    var value: Value {
        get { self.view.control.value }
        set { self.view.control.value = newValue }
    }

    var connected: Bool {
        get { self.view.connected ?? false }
        set { self.view.connected = newValue }
    }

    var hasChanges: Bool {
        get { self.view.hasChanges }
        set { self.view.hasChanges = newValue }
    }

    var label: String {
        get { self.view.label }
        set { self.view.label = newValue }
    }

    var disabled: Bool {
        get { false }
        set { self.view.setDisabled(newValue) }
    }

    var restoreButtonPublisher: PassthroughSubject<(), Never> {
        self.view.restoreButtonPublisher
    }

    var portButtonPublisher: PassthroughSubject<(), Never> {
        self.view.portButtonPublisher
    }

    var cancellables: Set<AnyCancellable> = []

    var changePublisher: PassthroughSubject<Change<Value>, Never> = .init()

    init(view: InnerView) {
        self.view = view
        self.view.connected = false
        self.view.hasChanges = false
    }

    init<C>(_ control: C, configuration: PropertyView.Configuration = .regular)
    where C: Control<Values::Value, NodeInputControlConfiguration, NodeInputControlContext> {
        self.view = .init(control.eraseToAnyNodeInputValueControl(), configuration: configuration)
        self.view.control.onChange = { [weak self] change in
            print("node input change: \(change)")
            self?.changePublisher.send(change)
        }
    }

    public func setDisabled(_ disabled: Bool) {
        self.view.setDisabled(disabled)
    }
}

struct NodeInputControlContext {
}

enum NodeInputControlConfiguration {
    case float(FloatControlConfiguration)
    case angle(AngleControlConfiguration)
    case picker(PickerControlConfiguration)
    case int(IntControlConfiguration)
    case nothing

    var float: FloatControlConfiguration? {
        switch self {
        case .float(let float): float
        default: nil
        }
    }

    var int: IntControlConfiguration? {
        switch self {
        case .int(let int): int
        default: nil
        }
    }

    var angle: AngleControlConfiguration? {
        switch self {
        case .angle(let angle): angle
        default: nil
        }
    }

    var picker: PickerControlConfiguration? {
        switch self {
        case .picker(let picker): picker
        default: nil
        }
    }
}

final class AnyNodeInputValueControl: Control<Values::Value, NodeInputControlConfiguration, NodeInputControlContext> {
    var value: Values.Value {
        get { self.inner.value }
        set { self.inner.value = newValue }
    }

    var context: NodeInputControlContext {
        get { self.inner.context }
        set { self.inner.context = newValue }
    }

    var configuration: NodeInputControlConfiguration {
        get { self.inner.configuration }
        set { self.inner.configuration = newValue }
    }

    var view: XView {
        self.inner.view
    }

    var auxiliaryView: XView? {
        self.inner.auxiliaryView
    }

    var onChange: ((Change<Values.Value>) -> ())? {
        get { self.inner.onChange }
        set { self.inner.onChange = newValue }
    }

    var inner: any Control<Values::Value, NodeInputControlConfiguration, NodeInputControlContext>

    init<C>(_ inner: C) where C: Control<Values::Value, NodeInputControlConfiguration, NodeInputControlContext> {
        self.inner = inner
    }

    func setDisabled(_ disabled: Bool) {
        self.inner.setDisabled(disabled)
    }
}

extension Control
where Value == Values::Value, Context == NodeInputControlContext, Configuration == NodeInputControlConfiguration {
    func eraseToAnyNodeInputValueControl() -> AnyNodeInputValueControl {
        .init(self)
    }
}

extension NodeInputControl {
    static func float(
        _ value: Value,
        _ configuration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2))
    ) -> NodeInputControl {
        NodeInputControl(
            FloatControl.map(
                value,
                configuration: .float(.init(drag: configuration)),
                context: NodeInputControlContext(),
                makeControl: { value, configuration, context in .init(value, configuration: configuration) },
                bij: .init(to: { .float($0) }, from: { $0.maybeFloat ?? 0.0 }),
                configMap: { config in
                    .init(drag: config.float?.drag ?? .free(.init()))
                },
                contextMap: { _ in }
            ),
            configuration: .regular
        )
    }

    static func angle(
        _ value: Value,
        range: ClosedRange<Double>?
    ) -> NodeInputControl {
        .init(
            AngleControl.map(
                value,
                configuration: .angle(.init(range: range)),
                context: .init(),
                makeControl: { value, configuration, context in
                    .init(value, configuration: configuration)
                },
                bij: .init(to: { .float($0) }, from: { $0.maybeFloat ?? 0.0 }),
                configMap: { .init(range: $0.angle?.range ?? nil) },
                contextMap: { _ in }
            ),
            configuration: .regular
        )
    }

    static func bool(_ value: Value) -> NodeInputControl {
        NodeInputControl(
            BoolControl.map(
                value,
                configuration: .nothing,
                context: .init(),
                makeControl: { value, _, _ in .init(value) },
                bij: .init(to: { .bool($0) }, from: { $0.maybeBool ?? false }),
                configMap: { _ in },
                contextMap: { _ in }
            ),
            configuration: .compact
        )
    }

    static func int(_ value: Value, _ range: IntControlConfiguration.Range = .none) -> NodeInputControl {
        NodeInputControl(
            IntControl.map(
                value,
                configuration: .int(.init(range: range)),
                context: .init(),
                makeControl: { value, configuration, _ in .init(value, configuration: configuration) },
                bij: .init(to: { .int($0) }, from: { $0.maybeInt ?? 0 }),
                configMap: { $0.int ?? .init(range: .none) },
                contextMap: { _ in }
            ),
            configuration: .regular
        )
    }

    static func picker(_ value: Value, options: [String]) -> NodeInputControl {
        NodeInputControl(
            PickerControl.map(
                value,
                configuration: .picker(.init(options: options)),
                context: .init(),
                makeControl: { value, configuration, _ in .init(value, configuration: configuration) },
                bij: .init(to: { .int($0) }, from: { $0.maybeInt ?? 0 }),
                configMap: { $0.picker ?? .init(options: []) },
                contextMap: { _ in }
            ),
            configuration: .compact
        )
    }

    static func color(_ value: Value) -> NodeInputControl {
        NodeInputControl(
            ColorControl.map(
                value,
                configuration: .nothing,
                context: .init(),
                makeControl: { value, _, _ in ColorControl(value) },
                bij: .init(
                    to: { .color4(.init(nsColor: $0) ?? .init(red: 0, green: 0, blue: 0, alpha: 1)) },
                    from: { $0.maybeColor4?.nsColor ?? .black }
                ),
                configMap: { _ in },
                contextMap: { _ in }
            ),
            configuration: .regular
        )
    }

    static func staticLabel(_ value: Value) -> NodeInputControl {
        .init(
            StaticLabelControl.map(
                value,
                configuration: .nothing,
                context: .init(),
                makeControl: { value, _, _ in .init(value) },
                bij: .init(to: { .string($0) }, from: { "\($0)" }),
                configMap: { _ in },
                contextMap: { _ in }
            ),
            configuration: .regular
        )
    }

}
