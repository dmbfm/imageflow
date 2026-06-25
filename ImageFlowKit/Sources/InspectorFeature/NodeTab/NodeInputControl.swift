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
    case vector(VectorControlConfiguration)
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

    var vector: VectorControlConfiguration? {
        switch self {
        case .vector(let vector): vector
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

    static func vector(
        _ value: Value,
        dragConfiguration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
        labels: [String],
        bij: Bijection<[Double], Value>,
    ) -> NodeInputControl {
        return NodeInputControl(
            VectorControl.map(
                value,
                configuration: .vector(.init(drag: dragConfiguration, labels: labels)),
                context: .init(),
                makeControl: { value, configuration, _ in VectorControl(value, configuration: configuration) },
                bij: bij,
                configMap: {
                    if let config = $0.vector {
                        return .init(drag: config.drag, labels: config.labels)
                    } else {
                        return .init(drag: dragConfiguration)
                    }
                },
                contextMap: { _ in }
            ),
            configuration: .regular
        )
    }

    static func vector2(
        _ value: Value,
        dragConfiguration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
    ) -> NodeInputControl {
        Self.vector(
            value,
            dragConfiguration: dragConfiguration,
            labels: ["x", "y"],
            bij: .init(
                to: { .vector2(.init(x: $0[0], y: $0[1])) },
                from: {
                    if let v = $0.maybeVector2 {
                        return [v.x, v.y]
                    } else {
                        return [0, 0]
                    }
                }
            )
        )
    }

    static func vector3(
        _ value: Value,
        dragConfiguration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
    ) -> NodeInputControl {
        Self.vector(
            value,
            dragConfiguration: dragConfiguration,
            labels: ["x", "y", "z"],
            bij: .init(
                to: { .vector3(.init(x: $0[0], y: $0[1], z: $0[2])) },
                from: {
                    if let v = $0.maybeVector3 {
                        return [v.x, v.y, v.z]
                    } else {
                        return [0, 0, 0]
                    }
                }
            )
        )
    }

    static func vector4(
        _ value: Value,
        dragConfiguration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
    ) -> NodeInputControl {
        Self.vector(
            value,
            dragConfiguration: dragConfiguration,
            labels: ["x", "y", "z", "w"],
            bij: .init(
                to: { .vector4(.init(x: $0[0], y: $0[1], z: $0[2], w: $0[3])) },
                from: {
                    if let v = $0.maybeVector4 {
                        return [v.x, v.y, v.z, v.w]
                    } else {
                        return [0, 0, 0, 0]
                    }
                }
            )
        )
    }

    static func rect(
        _ value: Value,
        dragConfiguration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
    ) -> NodeInputControl {
        Self.vector(
            value,
            dragConfiguration: dragConfiguration,
            labels: ["x", "y", "width", "height"],
            bij: .init(
                to: { .rect(.init(x: $0[0], y: $0[1], width: $0[2], height: $0[3])) },
                from: {
                    if let r = $0.maybeRect {
                        return [r.origin.x, r.origin.y, r.size.width, r.size.height]
                    } else {
                        return [0, 0, 0, 0]
                    }
                }
            )
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
