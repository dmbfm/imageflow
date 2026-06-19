import Combine
import Helpers
import Values
import XKit

@MainActor
final class NodeInputControl: Rx, WithRef {

    typealias InnerView = PropertyControlView<Values::Value, NodeInputControlContext, AnyNodeInputValueControl>

    public private(set) var view: InnerView

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

    var cancellables: Set<AnyCancellable> = []

    init(view: InnerView) {
        self.view = view
        self.view.connected = false
        self.view.hasChanges = false
    }

    init<C>(_ control: C, configuration: PropertyView.Configuration = .regular)
    where C: Control<Values::Value, NodeInputControlContext> {
        self.view = .init(control.eraseToAnyNodeInputValueControl(), configuration: configuration)
    }

}

struct NodeInputControlContext {
}

final class AnyNodeInputValueControl: Control<Values::Value, NodeInputControlContext> {
    var value: Values.Value {
        get { self.inner.value }
        set { self.inner.value = newValue }
    }

    var context: NodeInputControlContext {
        get { self.inner.context }
        set { self.inner.context = newValue }
    }

    var view: XView {
        self.inner.view
    }

    var onChange: ((Change<Values.Value>) -> ())? {
        get { self.inner.onChange }
        set { self.inner.onChange = newValue }
    }

    var inner: any Control<Values::Value, NodeInputControlContext>

    init<C>(_ inner: C) where C: Control<Values::Value, NodeInputControlContext> {
        self.inner = inner
    }
}

extension Control where Value == Values::Value, Context == NodeInputControlContext {
    func eraseToAnyNodeInputValueControl() -> AnyNodeInputValueControl {
        .init(self)
    }
}

@MainActor
final class ControlThatUsesContext: Control<Values::Value, NodeInputControlContext> {
    var value: Values.Value

    var context: NodeInputControlContext

    let view: XKit.XView

    var onChange: ((Change<Values.Value>) -> ())?

    init(_ value: Value, context: NodeInputControlContext) {
        self.value = value
        self.context = context
        self.view = .init()
    }
}

@MainActor
func f() {
    var _ = NodeInputControl(
        BoolControl.map(
            .bool(false),
            bij: .init(to: { .bool($0) }, from: { $0.maybeBool ?? false }),
            make: { BoolControl($0) }
        ).overContext(.init()),
        configuration: .compact
    )

    var _ = NodeInputControl(ControlThatUsesContext(.int(0), context: .init()), configuration: .regular)
}
