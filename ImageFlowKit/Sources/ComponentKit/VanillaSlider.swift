import Combine
import Helpers
import XKit

public final class VanillaSlider: XView, WithRef {
    @PublishedEx public var value: Double = 0.0 {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var onChange: ((Double) -> ())?

    public var numberOfTickMarks: Int {
        get { self.inner.numberOfTickMarks }
        set { self.inner.numberOfTickMarks = newValue }
    }

    public var allowsTickMarkValuesOnly: Bool {
        get { self.inner.allowsTickMarkValuesOnly }
        set { self.inner.allowsTickMarkValuesOnly = newValue }
    }

    public override var intrinsicContentSize: NSSize {
        self.inner.intrinsicContentSize
        // .init(width: Self.noIntrinsicMetric, height: self.inner.intrinsicContentSize.height)
    }

    public lazy var inner: NSSlider = {
        let slider = NSSlider(
            value: self.value,
            minValue: self.minValue,
            maxValue: self.maxValue,
            target: self,
            action: #selector(Self.handler)
        )
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    private let minValue: Double
    private let maxValue: Double

    public init(_ value: Double = 0.0, minValue: Double = 0.0, maxValue: Double = 10.0) {
        self.value = value
        self.minValue = minValue
        self.maxValue = maxValue

        super.init(frame: .zero)

        self.addSubview(self.inner)
        self.inner.constraintToFillSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handler() {
        self.value = self.inner.doubleValue
        self.onChange?(self.value)
    }

    private func update() {
        if self.inner.doubleValue != self.value {
            self.inner.doubleValue = self.value
        }
    }
}
