import Helpers
import XKit

public final class MinMaxLabeledSliderArray: XView, WithRef {
    public var values: [MinMax] = [] {
        didSet {
            self.updateValues()
        }
    }

    public var spacing: CGFloat = 4.0 {
        didSet {
            self.stackView.spacing = spacing
        }
    }

    public private(set) var sliders: [MinMaxLabeledSlider] = []
    public var onChange: ((Int, MinMaxSlider.Change) -> ())?
    public var labelForRow: ((Int) -> String)? {
        didSet { self.reloadLabels() }
    }
    public var formatter: FloatingPointFormatStyle<Double> {
        didSet {
            for slider in self.sliders {
                slider.formatter = self.formatter
            }
        }
    }
    public lazy var stackView: VStack = {
        VStack(
            alignment: .fill,
            spacing: self.spacing,
            views: []
        )
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    private var labels: [Label] = []
    private var labelWidthConstraints: [NSLayoutConstraint] = []
    private var range: ClosedRange<Double>

    // public var disabled: Bool {
    //     get { !self.isEnabled }
    //     set { self.isEnabled = !newValue }
    // }

    // public var isEnabled = true {
    //     didSet {
    //         for input in self.sliders {
    //             input.isEnabled = self.isEnabled
    //         }
    //     }
    // }
    //

    public init(
        _ values: [MinMax],
        range: ClosedRange<Double> = 0...1,
        formatter: FloatingPointFormatStyle<Double> = .number.precision(.fractionLength(2)),
    ) {
        self.values = values
        self.formatter = formatter
        self.range = range

        super.init(frame: .zero)

        self.setupView()
        self.repopulateRows()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview()
    }

    private func repopulateRows() {
        self.labels = []
        self.sliders = []
        self.stackView.removeAllViews()
        let views = self.values.enumerated().map({ index, value in
            HStack(views: [
                Padded(
                    Label(self.resolve(labelForRow: index))
                        .with(\.alignment, .right)
                        .with(\.textColor, .system.secondaryLabel)
                        .withRef({ self.labels.append($0) }),
                    insets: .init(top: 0, left: 0, bottom: 14, right: 0)
                ),
                MinMaxLabeledSlider(value, range: self.range)
                    .with(\.onChange, { [weak self] change in self?.onChangeHandler(index, change) })
                    .withRef({ self.sliders.append($0) })
                    .withContentHuggingPriority(.defaultLow - 10, for: .horizontal),
            ])
        })
        for view in views {
            self.stackView.addView(view)
        }

        self.updateLabelColumnConstraints()
    }

    func updateLabelColumnConstraints() {
        self.labelWidthConstraints.forEach({ $0.isActive = false })
        self.labelWidthConstraints = []
        let labelColumnWidth: CGFloat = self.labels.reduce(
            0,
            { acc, label in max(acc, label.intrinsicContentSize.width) }
        )
        self.labelWidthConstraints = self.labels.map({ $0.widthAnchor.constraint(equalToConstant: labelColumnWidth) })
        NSLayoutConstraint.activate(self.labelWidthConstraints)
    }

    private func resolve(labelForRow row: Int) -> String {
        self.labelForRow?(row) ?? ""
    }

    private func onChangeHandler(_ index: Int, _ change: MinMaxSlider.Change) {
        self.onChange?(index, change)
    }

    private func updateValues() {
        let needsRepopulateRows = self.values.count != self.labels.count

        if needsRepopulateRows {
            self.repopulateRows()
        }

        for (index, value) in self.values.enumerated() {
            let input = self.sliders[index]
            if input.value != value {
                input.value = value
            }
        }
    }

    private func reloadLabels() {
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
}

#Preview {
    MinMaxLabeledSliderArray(
        [
            .init(min: 0, max: 1),
            .init(min: 0, max: 1),
            .init(min: 0, max: 1),
        ],
        range: 0...1
    )
    .with(
        \.labelForRow,
        {
            switch $0 {
            case 0: "red"
            case 1: "green"
            default: "blue"
            }
        }
    )
    .with(\.onChange, { print("change: \($0): \($1)") })
    .constrainingWidth(toConstant: 200)
}
