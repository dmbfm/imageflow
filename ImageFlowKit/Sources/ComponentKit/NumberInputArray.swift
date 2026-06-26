import Combine
import Helpers
import XKit

/// A view that consists of a vertical array of labeled `NumberInput`s.
public final class NumberInputArray: XView, Rx, WithRef {
    /// The current set of values, each value corresponding to one row.
    public var values: [Double] = [] {
        didSet {
            self.updateValues()
        }
    }

    /// The spacing between rows.
    public var spacing: CGFloat = 4.0 {
        didSet {
            self.stackView.spacing = spacing
        }
    }

    /// Required by `Rx`
    public var cancellables: Set<AnyCancellable> = []

    /// The `Label` views.
    public var labels: [Label] = []

    /// The `NumberInput` views.
    public var numberInputs: [NumberInput] = []

    public var disabled: Bool {
        get { !self.isEnabled }
        set { self.isEnabled = !newValue }
    }

    public var isEnabled = true {
        didSet {
            for input in self.numberInputs {
                input.isEnabled = self.isEnabled
            }
        }
    }

    public var dragConfiguration: NumberInput.DragConfiguration {
        didSet {
            for input in self.numberInputs {
                input.dragConfiguration = self.dragConfiguration
            }
        }
    }

    /// Publishes the latest set of values.
    public var publisher: CurrentValueSubject<[Double], Never>

    private var columnConstraints: [NSLayoutConstraint] = []

    private var labelWidthConstraints: [NSLayoutConstraint] = []

    private var _onChange: ((Int, NumberInput.Change) -> ())?

    private var _labelForRow: ((Int) -> String)?

    /// The `VStack` that holds all the rows.
    public lazy var stackView: VStack = {
        VStack(
            alignment: .fill,
            spacing: self.spacing,
            views: []
        )
    }()

    private var style: TextFieldStyle

    public var formatter: FloatingPointFormatStyle<Double> {
        didSet {
            for input in self.numberInputs {
                input.formatter = self.formatter
            }
        }
    }

    /// Creates a new `NumberInputArray` instance.
    /// - Parameters:
    ///   - values: The set of values for each row.
    ///   - formatter: The number formatter.
    ///   - style: The style of the `NumberInput`s.
    public init(
        _ values: [Double],
        formatter: FloatingPointFormatStyle<Double> = .number,
        dragConfiguration: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2)),
        style: TextFieldStyle = .default
    ) {
        self.values = values
        self.publisher = .init(values)
        self.style = style
        self.formatter = formatter
        self.dragConfiguration = dragConfiguration

        super.init(frame: .zero)

        self.addSubview(self.stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.constraintToFillSuperview()

        self.repopulateRows()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sets a closure to be called whenever the user performs an action
    /// that produces a change in the values.
    /// - Parameter perform: The closure.
    /// - Returns: The current instance.
    @discardableResult
    public func onChange(_ perform: @escaping (Int, NumberInput.Change) -> ()) -> Self {
        self._onChange = perform
        return self
    }

    /// Sets a closure to be called to provide values for the labels of each
    /// row.
    /// - Parameter closure: A closure that returns a `String` that is that
    /// represents the label text at the given index/row.
    /// - Returns: The current instance.
    @discardableResult
    public func labelForRow(_ closure: @escaping (Int) -> String) -> Self {
        self._labelForRow = closure
        self.reloadLabels()
        return self
    }

    /// Reloads the text labels for all the rows.
    public func reloadLabels() {
        var needsToUpdateConstraints = false
        for (index, label) in self.labels.enumerated() {
            let newText = self.resolve(labelForRow: index)
            if label.text != newText {
                label.text = newText
                needsToUpdateConstraints = true
            }
        }

        if needsToUpdateConstraints {
            self.updateLabelColumnConstraints()
        }
    }

    /// Repopulate the rows
    private func repopulateRows() {
        self.labels = []
        self.numberInputs = []
        self.stackView.removeAllViews()
        let views = self.values.enumerated().map({ index, value in
            HStack(views: [
                Label(self.resolve(labelForRow: index))
                    .with(\.alignment, .right)
                    .withRef({ self.labels.append($0) }),
                NumberInput(value, formatter: self.formatter, style: self.style)
                    .with(\.dragConfiguration, self.dragConfiguration)
                    .onChange({ [weak self] in self?.numberInputChange(index, change: $0) })
                    .withRef({ self.numberInputs.append($0) })
                    .withContentHuggingPriority(.defaultLow - 10, for: .horizontal),
            ])
        })
        for view in views {
            self.stackView.addView(view)
        }
        self.updateLabelColumnConstraints()
    }

    private func numberInputChange(_ index: Int, change: NumberInput.Change) {
        self.values[index] = change.newValue
        self._onChange?(index, change)
        self.publisher.send(self.values)
    }

    private func resolve(labelForRow row: Int) -> String {
        self._labelForRow?(row) ?? "\(row)"
    }

    private func updateLabelColumnConstraints() {
        self.labelWidthConstraints.forEach({ $0.isActive = false })
        self.labelWidthConstraints = []
        let labelColumnWidth: CGFloat = self.labels.reduce(
            0,
            { acc, label in max(acc, label.intrinsicContentSize.width) }
        )
        self.labelWidthConstraints = self.labels.map({ $0.widthAnchor.constraint(equalToConstant: labelColumnWidth) })
        NSLayoutConstraint.activate(self.labelWidthConstraints)
    }

    private func updateValues() {
        let needsRepopulateRows = self.values.count != self.labels.count

        if needsRepopulateRows {
            self.repopulateRows()
        }

        for (index, value) in self.values.enumerated() {
            let input = self.numberInputs[index]
            if input.value != value {
                input.value = value
            }
        }
    }
}

class Store {
    var value: [Double] = [1.0, 2.0, 3.0, 10.0] {
        didSet {
            self.publisher.send(value)
        }
    }

    var publisher: CurrentValueSubject<[Double], Never>
    var cancellables: Set<AnyCancellable> = []

    init() {
        self.publisher = .init(self.value)
    }

    func connect(_ source: any Publisher<[Double], Never>) {
        source.sink { newValue in
            self.value = newValue.map({ x in x.clamped(to: 0...100) })
        }.store(in: &self.cancellables)
    }
}

#Preview("Rx Store") {
    {
        let store = Store()
        return NumberInputArray(store.value)
            .labelForRow({
                switch $0 {
                case 0: "x"
                case 1: "y"
                case 2: "z"
                case 3: "www"
                default: ""
                }
            })
            .rx(store.publisher, kp: \.values)
            .withRef({ store.connect($0.publisher) })
            .constrainingWidth(toConstant: 300)
    }()
}

#Preview {
    NumberInputArray([1.0, 2.0, 3.0, 4.0])
        .labelForRow({
            switch $0 {
            case 0: "x"
            case 1: "y"
            case 2: "z"
            case 3: "www"
            default: ""
            }
        })
        .onChange({ print("change: \($0):\($1)") })
        .constrainingWidth(toConstant: 300)
}
