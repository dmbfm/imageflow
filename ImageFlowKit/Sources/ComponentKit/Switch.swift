import Combine
import Helpers
import XKit

public final class Switch: XView, Rx, WithRef {

    public var value: Bool {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var componentSize: ComponentSize = .small {
        didSet {
            if self.componentSize != oldValue {
                self._switch.controlSize = self.componentSize.controlSize
            }
        }
    }

    public var cancellables: Set<AnyCancellable> = []

    public var publisher: CurrentValueSubject<Bool, Never>

    private var _switch: XSwitch = .init()

    private var _onChange: ((Bool) -> ())?

    public init(_ value: Bool) {
        self.value = value
        self.publisher = .init(value)

        super.init(frame: .zero)

        self.addSubview(self._switch)
        self._switch.translatesAutoresizingMaskIntoConstraints = false
        self._switch.constraintToFillSuperview()
        self._switch.controlSize = self.componentSize.controlSize
        self._switch.target = self
        self._switch.action = #selector(Self.handler)

        self.update()
    }

    @objc func handler() {
        self.value = self._switch.state == .on
        self._onChange?(self.value)
    }

    @discardableResult
    public func onChange(_ perform: @escaping (Bool) -> ()) -> Self {
        self._onChange = perform
        return self
    }

    func update() {
        self._switch.state = self.value ? .on : .off
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    Switch(true)
        .onChange { print("value: \($0)") }
}
