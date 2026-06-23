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
    case nothing

    var float: FloatControlConfiguration? {
        switch self {
        case .float(let float): float
        default: nil
        }
    }

    var angle: AngleControlConfiguration? {
        switch self {
        case .angle(let angle): angle
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
                bij: .init(to: { .float($0) }, from: { $0.maybeFloat ?? 0.0 }),
                make: { .init($0) }
            ).mapConfiguration(
                .float(.init(drag: configuration)),
                map: { $0.float ?? .init(drag: .free(.init())) }
            ).overContext(.init()),
            configuration: .regular
        )
    }

    static func angle(
        _ value: Value,
        range: ClosedRange<Double>?
    ) -> NodeInputControl {
        let range: ClosedRange<Double>? = range.flatMap({ range in
            if abs(range.span - 2 * .pi) < 0.001 {
                return nil
            } else {
                return range
            }
        })
        return NodeInputControl(
            AngleControl.map(
                value,
                bij: .init(to: { .float($0) }, from: { $0.maybeFloat ?? 0.0 }),
                make: { .init($0) }
            )
            .mapConfiguration(
                .angle(.init(range: range)),
                map: { $0.angle ?? .init() }
            )
            .overContext(.init()),
            configuration: .regular
        )
    }

    static func bool(_ value: Value) -> NodeInputControl {
        NodeInputControl(
            BoolControl.map(
                value,
                bij: .init(to: { .bool($0) }, from: { $0.maybeBool ?? false }),
                make: { .init($0) }
            )
            .mapConfiguration(.nothing, map: { _ in () })
            .overContext(.init()),
            configuration: .compact
        )
    }

    static func int(_ value: Value, _ range: IntControlConfiguration.Range = .none) -> NodeInputControl {
        NodeInputControl(
            IntControl.map(
                value,
                bij: .init(to: { .int($0) }, from: { $0.maybeInt ?? 0 }),
                make: { .init($0) }
            )
            .mapConfiguration(.nothing, map: { _ in .init(range: range) })
            .overContext(.init()),
            configuration: .regular
        )
    }

    static func picker(_ value: Value, options: [String]) -> NodeInputControl {
        NodeInputControl(
            PickerControl.map(
                value,
                bij: .init(to: { .int($0) }, from: { $0.maybeInt ?? 0 }),
                make: { .init($0) }
            )
            .mapConfiguration(.nothing, map: { _ in .init(options: options) })
            .overContext(.init()),
            configuration: .compact
        )
    }

}
