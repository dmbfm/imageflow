import Combine
import FormatKit
import Helpers
import XKit

public final class MinMaxLabeledSlider: XView, WithRef {

    public var value: MinMax {
        get { self.slider.value }
        set {
            self.slider.value = newValue
        }
    }

    public var onChange: ((MinMaxSlider.Change) -> ())? {
        get { self.slider.onChange }
        set { self.slider.onChange = newValue }
    }

    public var range: ClosedRange<Double> {
        self.slider.range
    }

    public var formatResolver: DoubleFormatResolver {
        didSet {
            self.updateFormatResolver()
        }
    }

    private var formatResolverCancellable: AnyCancellable?

    public var formatter: FloatingPointFormatStyle<Double> {
        self.formatResolver.current
    }

    var slider: MinMaxSlider

    var font: XFont {
        .monospacedSystemFont(ofSize: 10, weight: .regular)
    }

    lazy var minLabelView: Label = {
        Label("\(self.value.min)")
            .with(\.font, self.font)
            .with(\.textColor, .system.secondaryLabel)
    }()

    lazy var maxLabelView: Label = {
        Label("\(self.value.max)")
            .with(\.font, self.font)
            .with(\.textColor, .system.secondaryLabel)
    }()

    lazy var stackView: VStack = {
        VStack(
            alignment: .fill,
            spacing: 2,
            views: [
                self.slider,
                HStack(views: [
                    self.minLabelView,
                    Spacer(),
                    self.maxLabelView,
                ]),
            ]
        ).with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    private var cancellables: Set<AnyCancellable> = []

    public init(
        _ value: MinMax,
        range: ClosedRange<Double>,
        formatResolver: DoubleFormatResolver = .just(.number.precision(.fractionLength(2)))
    ) {
        self.slider = .init(value, range: range)
        self.formatResolver = formatResolver

        super.init(frame: .zero)

        self.slider.$value.sink { [weak self] value in
            self?.updateLabels()
        }.store(in: &self.cancellables)

        self.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview()

        self.updateFormatResolver()
        self.updateLabels()
    }

    func updateFormatResolver() {
        self.formatResolverCancellable = self.formatResolver.publisher.sink { [unowned self] _ in
            self.updateLabels()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateLabels() {
        self.minLabelView.text = "\(value.min.formatted(self.formatter))"
        self.maxLabelView.text = "\(value.max.formatted(self.formatter))"
    }
}

#Preview {
    VStack(views: [
        MinMaxLabeledSlider(.init(min: 125, max: 175), range: 100...200),
        MinMaxLabeledSlider(.init(min: 0, max: 1), range: 0...1),
    ])
    .constrainingWidth(toConstant: 220)
}
