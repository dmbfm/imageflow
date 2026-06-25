import Combine
import Helpers
import XKit

/// Represents a controller class (a pseude or lightweight view controller) that
/// manages a view that is edits or displays a `Value`.
protocol Control<Value, Configuration, Context>: AnyObject {
    /// The type of the value that this controller edits or displays.
    associatedtype Value: Sendable & Equatable
    /// A `Context` type used for additional... context for the control.
    associatedtype Context
    /// A `Configuration` type used for additional control-specific
    // configuration. For instance, sometimes you want controls to share the same
    // `Value` and `Context` but with additional options that are distinct.
    associatedtype Configuration
    /// Holds the `Value` of the control.
    var value: Value { get set }
    /// A description
    var configuration: Configuration { get set }
    /// Holds the `Context` of the control.
    var context: Context { get set }
    /// The view that is managed by the control.
    var view: XView { get }
    /// An auxiliary view the control may use to display additional context to
    /// the user, depending on the context.
    var auxiliaryView: XView? { get }
    /// Notifies consumers of changes in the `Value`.
    var onChange: ((Change<Value>) -> ())? { get set }
    /// Disable/enagle the control.
    func setDisabled(_ disabled: Bool)
}

extension Control {
    var auxiliaryView: XView? {
        nil
    }
}

/// Represents a change in the `Value` of a `Control`
struct Change<Value> where Value: Sendable & Equatable {
    /// The new value
    var newValue: Value
    /// The previous value
    var oldValue: Value?
    /// If `true`, the change represents a "final" change to be commited (e.g.,
    /// an undo item can be registrered.) If false, this is a temporary/transient
    /// change.
    var commit: Bool
}

final class MappedControl<Value, Configuration, Context, OldValue, OldConfiguration, OldContext, C>:
    Control<Value, Configuration, Context>
where
    Value: Sendable & Equatable,
    OldValue: Sendable & Equatable,
    C: Control<OldValue, OldConfiguration, OldContext>
{
    var view: XView {
        self.control.view
    }

    var auxiliaryView: XView? {
        self.control.auxiliaryView
    }

    var onChange: ((Change<Value>) -> ())?

    var value: Value {
        get { self.bij.to(self.control.value) }
        set { self.control.value = self.bij.from(newValue) }
    }

    var configuration: Configuration {
        didSet {
            self.control.configuration = self.configMap(self.configuration)
        }
    }

    var context: Context {
        didSet {
            self.control.context = self.contextMap(self.context)
        }
    }

    var control: C

    var bij: Bijection<OldValue, Value>

    var configMap: (Configuration) -> (OldConfiguration)

    var contextMap: (Context) -> (OldContext)

    func setDisabled(_ disabled: Bool) {
        self.control.setDisabled(disabled)
    }

    init(
        _ value: Value,
        configuration: Configuration,
        context: Context,
        makeControl: (OldValue, OldConfiguration, OldContext) -> C,
        bij: Bijection<OldValue, Value>,
        configMap: @escaping (Configuration) -> (OldConfiguration),
        contextMap: @escaping (Context) -> (OldContext),
    ) {
        self.configuration = configuration
        self.context = context
        self.control = makeControl(bij.from(value), configMap(configuration), contextMap(context))
        self.bij = bij
        self.configMap = configMap
        self.contextMap = contextMap

        self.control.onChange = { [weak self] change in
            guard let self else { return }
            self.onChange?(
                .init(
                    newValue: self.bij.to(change.newValue),
                    oldValue: change.oldValue.map({ self.bij.to($0) }),
                    commit: change.commit
                )
            )
        }
    }
}

extension Control {
    static func map<NewValue, NewConfiguration, NewContext>(
        _ value: NewValue,
        configuration: NewConfiguration,
        context: NewContext,
        makeControl: (Value, Configuration, Context) -> Self,
        bij: Bijection<Value, NewValue>,
        configMap: @escaping (NewConfiguration) -> (Configuration),
        contextMap: @escaping (NewContext) -> (Context),
    ) -> MappedControl<NewValue, NewConfiguration, NewContext, Value, Configuration, Context, Self> {
        .init(
            value,
            configuration: configuration,
            context: context,
            makeControl: makeControl,
            bij: bij,
            configMap: configMap,
            contextMap: contextMap
        )
    }
}
