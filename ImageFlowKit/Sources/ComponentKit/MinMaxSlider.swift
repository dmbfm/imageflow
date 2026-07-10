import Helpers
import XKit

public final class MinMaxSlider: XView, WithRef {

    // MARK: - Public

    @PublishedEx public var value: MinMax {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var onChange: ((Change) -> ())?

    public let range: ClosedRange<Double>

    public override var intrinsicContentSize: NSSize {
        .init(width: Self.noIntrinsicMetric, height: 28)
    }

    public init(_ value: MinMax, range: ClosedRange<Double>) {
        self.value = value
        self.range = range

        super.init(frame: .zero)

        self.setupView()
    }

    public struct Change: Sendable, Equatable {
        public var newValue: MinMax
        public var oldValue: MinMax
        public var commit: Bool
    }

    // MARK: - Internal

    private lazy var backgroundView: BackgroundView = {
        let view = BackgroundView(style: .default, progressMin: 0, progressMax: 0)
        view.minOffset = self.overlayView.thumbStyle.thickness
        return view
    }()

    fileprivate lazy var overlayView: ThumbOverlayView = {
        ThumbOverlayView(0, 0)
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.backgroundView)
        self.backgroundView.constraintToFillSuperview(insets: .init(vertical: 3, horizontal: 0))

        self.addSubview(self.overlayView)
        self.overlayView.constraintToFillSuperview()

        let gesture = NSPanGestureRecognizer(target: self, action: #selector(Self.dragHandler(_:)))
        self.overlayView.addGestureRecognizer(gesture)

        self.update()
    }

    private func update() {
        let min = self.range.progress(self.value.min)
        let max = self.range.progress(self.value.max)
        self.backgroundView.progressMin = min
        self.backgroundView.progressMax = max
        self.overlayView.min = min
        self.overlayView.max = max
    }

    private lazy var thumbDragController: ThumbDragController = {
        .init(self) { [weak self] in
            self?.value ?? .init(min: 0, max: 0)
        } thumbRectProvider: { [weak self] which in
            switch which {
            case .min: self?.overlayView.minThumbRect ?? .init()
            case .max: self?.overlayView.maxThumbRect ?? .init()
            }
        } rangeProvider: { [weak self] in
            self?.range ?? 0.0...1.0
        } onChange: { [weak self] change in
            guard let self else { return }
            self.value = change.newValue
            self.onChange?(change)
        }
    }()

    @objc
    private func dragHandler(_ gesture: NSPanGestureRecognizer) {
        self.thumbDragController.dragHandler(gesture)
    }
}

@MainActor
private final class ThumbDragController {
    var thumb: MinMax.MinOrMax?
    var valueAtDragStart: MinMax?
    var lastValue: MinMax = .init(min: 0, max: 0)

    var valueProvider: () -> MinMax
    var thumbRectProvider: (MinMax.MinOrMax) -> CGRect
    var rangeProvider: () -> ClosedRange<Double>
    var onChange: (MinMaxSlider.Change) -> ()

    init(
        _ owner: MinMaxSlider,
        valueProvider: @escaping () -> MinMax,
        thumbRectProvider: @escaping (MinMax.MinOrMax) -> CGRect,
        rangeProvider: @escaping () -> ClosedRange<Double>,
        onChange: @escaping (MinMaxSlider.Change) -> ()
    ) {
        self.valueProvider = valueProvider
        self.thumbRectProvider = thumbRectProvider
        self.rangeProvider = rangeProvider
        self.onChange = onChange
    }

    func dragHandler(_ gesture: NSPanGestureRecognizer) {
        guard let view = gesture.view else { return }

        let location = view.convert(gesture.location(in: nil), from: nil)
        let translation = gesture.translation(in: nil).x / view.bounds.width
        gesture.setTranslation(.zero, in: nil)

        switch gesture.state {
        case .began:
            let minRect = self.thumbRectProvider(.min)
            let maxRect = self.thumbRectProvider(.max)

            let eps = 8.0

            self.thumb =
                if minRect.with(\.origin.x, minRect.origin.x - eps)
                    .with(\.size.width, minRect.size.width + eps)
                    .contains(location)
                {
                    .min
                } else if maxRect.with(\.size.width, maxRect.size.width + eps)
                    .contains(location)
                {
                    .max
                } else {
                    nil
                }
            self.lastValue = self.valueProvider()
            self.valueAtDragStart = self.lastValue

        case .changed:
            if let thumb = self.thumb {
                if location.x < view.bounds.minX && translation > 0 { return }
                if location.x > view.bounds.maxX && translation < 0 { return }

                let newValue = self.lastValue.moving(
                    thumb,
                    byFraction: translation,
                    ofClampingRange: self.rangeProvider()
                )
                self.lastValue = newValue

                self.onChange(
                    .init(newValue: newValue, oldValue: lastValue, commit: false)
                )
            }

        default:
            if let oldValue = self.valueAtDragStart {
                if gesture.state == .ended {
                    self.onChange(
                        .init(newValue: self.lastValue, oldValue: oldValue, commit: true)
                    )
                } else {
                    self.onChange(
                        .init(newValue: oldValue, oldValue: self.lastValue, commit: false)
                    )
                }
            }
            self.thumb = nil
            self.valueAtDragStart = nil
        }
    }
}

private final class ThumbOverlayView: XView {

    // MARK: - Public

    public var min: CGFloat {
        didSet {
            self.updateGeometry()
            self.setNeedsDisplay()
        }
    }
    public var max: CGFloat {
        didSet {
            self.updateGeometry()
            self.setNeedsDisplay()
        }
    }
    public var thumbStyle: ThumbStyle = .init() { didSet { self.setNeedsDisplay() } }

    public private(set) var minThumbRect: CGRect = .init()
    public private(set) var maxThumbRect: CGRect = .init()

    public init(_ min: CGFloat, _ max: CGFloat) {
        self.min = min
        self.max = max

        super.init(frame: .zero)

        self.wantsLayer = true
        self.shadow = .init()
        self.withLayer { layer in
            layer.shadowColor = .black
            layer.shadowOpacity = 1.0
            layer.shadowRadius = 8
            layer.shadowOffset = .zero
            layer.masksToBounds = false
        }

        self.clipsToBounds = false
    }

    public struct ThumbStyle: Sendable, Equatable, With {
        public var thickness: CGFloat = 6
        public var heightFraction: CGFloat = 1.0
        public var cornerRadius: CGFloat = 2.0
        public var color: XColor = .init(white: 0.55, alpha: 1.0)

        public init() {

        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    private func updateGeometry() {
        let thickness = self.thumbStyle.thickness
        let heightFraction = self.thumbStyle.heightFraction

        let minPos = (bounds.width - 2 * thickness) * min.clamped(to: 0...1)
        let maxPos = thickness + (bounds.width - 2 * thickness) * max.clamped(to: 0...1)
        let h = heightFraction * bounds.height
        let y = 0.5 * bounds.height * (1.0 - heightFraction)

        self.minThumbRect = .init(
            x: minPos,
            y: y,
            width: thickness,
            height: h,
        )

        self.maxThumbRect = .init(
            x: maxPos,
            y: y,
            width: thickness,
            height: h,
        )
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.updateGeometry()

        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        let radius = self.thumbStyle.cornerRadius
        let color = self.thumbStyle.color.cgColor

        let pp = CGMutablePath()
        let p = CGPath(
            roundedRect: self.minThumbRect.with(\.size.width, self.minThumbRect.size.width - 0.5),
            cornerWidth: radius,
            cornerHeight: radius,
            transform: nil
        )
        ctx.addPath(
            p
        )
        ctx.setFillColor(color)
        ctx.fillPath()

        let p2 = CGPath(
            roundedRect: self.maxThumbRect
                .with(\.size.width, self.maxThumbRect.size.width - 0.5)
                .with(\.origin.x, self.maxThumbRect.origin.x + 0.5),
            cornerWidth: radius,
            cornerHeight: radius,
            transform: nil
        )
        ctx.addPath(p2)
        ctx.setFillColor(color)
        ctx.fillPath()
        ctx.setStrokeColor(.red)
        ctx.strokePath()

        pp.addPath(p)
        pp.addPath(p2)
        self.layer?.shadowPath = pp

    }
}
extension CGRect: With {}

#Preview {
    MinMaxSlider(.init(min: 125, max: 175), range: 100...200)
        .constrainingWidth(toConstant: 120)
}
