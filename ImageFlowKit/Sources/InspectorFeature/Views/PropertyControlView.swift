import Combine
import ComponentKit
import Helpers
import Values
import XKit

final class PropertyControlView<Value, Context, C>: XView, Rx, WithRef
where Value: Equatable & Sendable, C: Control<Value, Context> {

    public var connected: Bool? {
        get { self.propertyView.connected }
        set { self.propertyView.connected = newValue }
    }

    public var label: String {
        get { self.propertyView.label }
        set { self.propertyView.label = newValue }
    }

    public var hasChanges: Bool {
        get { self.propertyView.hasChanges }
        set { self.propertyView.hasChanges = newValue }
    }

    public var type: String? {
        get { self.propertyView.type }
        set { self.propertyView.type = newValue }
    }

    public var configuration: PropertyView.Configuration {
        get { self.propertyView.configuration }
        set { self.propertyView.configuration = newValue }
    }

    public private(set) var control: C

    public private(set) var propertyView: PropertyView

    var cancellables: Set<AnyCancellable> = []

    public init(_ control: C, configuration: PropertyView.Configuration = .regular) {
        self.control = control
        self.propertyView = .init(control.view, configuration: configuration)
        super.init(frame: .zero)

        self.propertyView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.propertyView)
        self.propertyView.constraintToFillSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    PropertyControlView(BoolControl(false), configuration: .compact)
        .with(\.label, "Enabled")
        .with(\.connected, false)
        .with(\.hasChanges, false)
        .with(\.type, nil)
        .constrainingWidth(toConstant: 300)
}
