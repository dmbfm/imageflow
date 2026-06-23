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

final class MappedConfigurationControl<Value, Context, OldConfiguration, NewConfiguration, C>: Control<
    Value, NewConfiguration, Context
>
where
    C: Control<Value, OldConfiguration, Context>
{
    var value: Value {
        get { self.control.value }
        set { self.control.value = newValue }
    }

    var configuration: NewConfiguration {
        didSet {
            self.control.configuration = self.map(self.configuration)
        }
    }

    var context: Context {
        get { self.control.context }
        set { self.control.context = newValue }
    }

    var view: XKit.XView {
        get { self.control.view }
    }

    var auxiliaryView: XView? {
        get { self.control.auxiliaryView }
    }

    var onChange: ((Change<Value>) -> ())? {
        get { self.control.onChange }
        set { self.control.onChange = newValue }
    }

    var control: C

    var map: (NewConfiguration) -> OldConfiguration

    init(_ control: C, _ configuration: NewConfiguration, map: @escaping (NewConfiguration) -> OldConfiguration) {
        self.control = control
        self.control.configuration = map(configuration)
        self.configuration = configuration
        self.map = map
    }

    func setDisabled(_ disabled: Bool) {
        self.control.setDisabled(disabled)
    }
}

/// Wraps a `Control<OldValue, Context>`, mapping values from `OldValue` to
/// `NewValue` using a  mapping given by `Bijection<OldValue, NewValue>`, producing
/// an object that is a `Control<NewValue, Context>`.
///
/// In a nutshell, this class maps
/// controls from one value type to another, while maintaining the same context type.
final class MappedControl<OldValue, NewValue, Context, Configuration, C>: Control<NewValue, Configuration, C.Context>
where
    OldValue: Sendable & Equatable,
    NewValue: Sendable & Equatable,
    C: Control<OldValue, Configuration, Context>
{
    var value: NewValue {
        get {
            self.bij.to(self.control.value)
        }
        set {
            self.control.value = self.bij.from(newValue)
        }
    }

    var context: C.Context {
        get { self.control.context }
        set { self.control.context = newValue }
    }

    var configuration: Configuration {
        get { self.control.configuration }
        set { self.control.configuration = newValue }
    }

    var control: C

    let bij: Bijection<OldValue, NewValue>

    var view: XKit.XView {
        self.control.view
    }

    var auxiliaryView: XView? {
        self.control.auxiliaryView
    }

    var onChange: ((Change<NewValue>) -> ())?

    var cancellables: Set<AnyCancellable> = []

    /// Creates a `MappedControl` that wraps the input control `C` over the given `Bijection`.
    /// - Parameters:
    ///   - control: The original control.
    ///   - bij: A `Bijection` that maps `OldValue`s to and from `NewValue`s.
    init(control: C, bij: Bijection<OldValue, NewValue>) {
        self.control = control
        self.bij = bij
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

    func setDisabled(_ disabled: Bool) {
        self.control.setDisabled(disabled)
    }
}

/// Wraps the original `Control<Value, NewContex>` creating an control instance
/// with a new context, i.e., `Control<Value, NewContext>`. It will "overwrite" the
/// original context, in the sense that consumers will only be able to interact with
/// the new context. This is mostly used to appease the type-system in some situations.
final class OverContextControl<Value, OldContext, NewContext, Configuration, C>: Control<
    Value, Configuration, NewContext
>
where C: Control<Value, Configuration, OldContext> {
    var value: Value {
        get { self.control.value }
        set { self.control.value = newValue }
    }

    var configuration: Configuration {
        get { self.control.configuration }
        set { self.control.configuration = newValue }
    }

    var view: XKit.XView {
        self.control.view
    }

    var auxiliaryView: XView? {
        self.control.auxiliaryView
    }

    var onChange: ((Change<Value>) -> ())? {
        get { self.control.onChange }
        set { self.control.onChange = newValue }
    }

    var context: NewContext

    var cancellables: Set<AnyCancellable> = []

    var control: C

    /// Creates a new control with the same `Value` as the original but over a new context.
    /// - Parameters:
    ///   - control: The original control.
    ///   - context: The value for the `NewContext`.
    init(
        control: C,
        context: NewContext,
    ) {
        self.control = control
        self.context = context
    }

    func setDisabled(_ disabled: Bool) {
        self.control.setDisabled(disabled)
    }
}

extension Control {
    /// Maps the current control to a new control instance over the same context
    /// but with a different value-type, mapped to and from the original `Value` via the
    /// provided `Bijection`.
    ///
    /// - Parameter bij: The `Bijection` tht maps `Value` to and from `NewValue`
    /// - Returns: An instance that conforms to `Control<NewValue, Self.Context>`.
    func map<NewValue>(
        _ bij: Bijection<Value, NewValue>
    ) -> MappedControl<Value, NewValue, Self.Context, Self.Configuration, Self> {
        .init(control: self, bij: bij)
    }

    /// Creates an instance that maps this control.
    /// - Parameters:
    ///   - value: The `NewValue` of the control.
    ///   - bij: The mapping bijection.
    ///   - make: A clojure used to create an instance of the original control.
    ///
    /// - Returns: An instance of the mapped control.
    static func map<NewValue>(
        _ value: NewValue,
        bij: Bijection<Value, NewValue>,
        make: (Value) -> Self
    ) -> MappedControl<Value, NewValue, Self.Context, Self.Configuration, Self> {
        .init(control: make(bij.from(value)), bij: bij)
    }

    /// Wraps thi control creating an instance of `Control` over the same value type but with a different context type.
    /// - Parameter context: The `NewContext` value/instance.
    /// - Returns: The instance of the control using the new context type.
    func overContext<NewContext>(
        _ context: NewContext
    ) -> OverContextControl<Value, Context, NewContext, Self.Configuration, Self> {
        .init(control: self, context: context)
    }

    func mapConfiguration<NewConfiguration>(
        _ configuration: NewConfiguration,
        map: @escaping (NewConfiguration) -> Self.Configuration
    ) -> MappedConfigurationControl<Value, Context, Self.Configuration, NewConfiguration, Self> {
        .init(self, configuration, map: map)
    }
}
