import Combine
import Helpers
import XKit

public final class Stepper: XView, Rx, WithRef {

    public var cancellables: Set<AnyCancellable> = []

    public var stepper: XStepper

    public var value: Double {
        get { self.stepper.doubleValue }
        set { self.stepper.doubleValue = newValue }
    }

    public var range: ClosedRange<Double>? {
        didSet {
            if self.range != oldValue {
                self.updateRange()
            }
        }
    }

    public var componentSize: ComponentSize = .small {
        didSet {
            if self.componentSize != oldValue {
                self.stepper.controlSize = self.componentSize.controlSize
            }
        }
    }

    public var increment: Double {
        get { self.stepper.increment }
        set { self.stepper.increment = newValue }
    }

    public var publisher: CurrentValueSubject<Double, Never>

    private var _onChange: ((Double) -> ())?

    public init(_ value: Double, increment: Double = 1.0, range: ClosedRange<Double>? = nil) {
        self.stepper = .init()
        self.publisher = .init(value)
        super.init(frame: .zero)

        self.addSubview(self.stepper)
        self.stepper.translatesAutoresizingMaskIntoConstraints = false
        self.stepper.constraintToFillSuperview()
        self.stepper.target = self
        self.stepper.action = #selector(Self.stepperAction)
        self.stepper.doubleValue = value
        self.stepper.increment = increment
        self.stepper.valueWraps = false
        self.stepper.autorepeat = true
        self.stepper.controlSize = self.componentSize.controlSize
        self.range = range

        self.updateRange()
    }

    public func updateRange() {
        if let range = self.range {
            self.stepper.maxValue = range.upperBound
            self.stepper.minValue = range.lowerBound
        } else {
            self.stepper.minValue = -Double.greatestFiniteMagnitude
            self.stepper.maxValue = Double.greatestFiniteMagnitude
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    public func onChange(_ perform: @escaping (Double) -> ()) -> Self {
        self._onChange = perform
        return self
    }

    @objc func stepperAction() {
        self._onChange?(self.stepper.doubleValue)
    }
}

#Preview {
    Stepper(0, increment: 1, range: nil)
}
