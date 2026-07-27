import Combine
import CoreImage
import CoreImage.CIFilterBuiltins
import Filters
import Helpers
import Values
import XKit

public final class GradientDataEditor: XView, WithRef {

    // MARK: - Public Interface

    @PublishedEx public var value: GradientData {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var onChange: ((Change) -> ())?

    public struct Change {
        public var newValue: GradientData
        public var oldValue: GradientData
        public var commit: Bool

        public init(newValue: GradientData, oldValue: GradientData, commit: Bool) {
            self.newValue = newValue
            self.oldValue = oldValue
            self.commit = commit
        }
    }

    // MARK: - Implementation

    private weak var noisePopoverController: NoisePopoverController?

    private var cancellables: Set<AnyCancellable> = []

    private lazy var interpPickerView: Picker = {
        Picker(["Linear", "Step", "Cubic"], selected: self.value.interpolation.rawValue)
            .with(\.controlSize, .small)
            .onChange { [unowned self] index in
                if let newValue = GradientData.InterpolationType(rawValue: index),
                    newValue != self.value.interpolation
                {
                    let oldValue = self.value
                    self.value.interpolation = newValue
                    self.onChange?(.init(newValue: self.value, oldValue: oldValue, commit: true))
                }
            }
    }()

    private lazy var noiseButton: Button = {
        Button(
            "",
            image: XImage(symbolName: "NoiseSymbolV2", bundle: .module, variableValue: 0.0)?
                .withSymbolConfiguration(.init(pointSize: 14, weight: .regular))
        ) {
            [unowned self] in self.noiseButtonClick()
        }
        .with(\.toolTip, "Noise Amount")
        .with(\.controlSize, .small)
    }()

    private lazy var stackView: VStack = {
        VStack(
            alignment: .fill,
            spacing: 4,
            views: [
                self.topStackView,
                self.slider,
                self.colorPicker,
            ]
        )
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
        .withRef { view in
            view.setCustomSpacing(16, after: self.topStackView)
            view.setCustomSpacing(16, after: self.slider)
        }
    }()

    private lazy var topStackView: Padded<HStack> = {
        Padded(
            HStack(views: [
                self.interpPickerView,
                self.noiseButton,

                Button("", systemSymbolName: "plus") { [unowned self] in
                    self.addStop()
                }
                .with(\.toolTip, "Add Stop")
                .with(\.controlSize, .small),

                Button("", systemSymbolName: "minus") { [unowned self] in
                    self.removeStop()
                }
                .with(\.toolTip, "Delete Stop")
                .with(\.controlSize, .small),

                Button("", systemSymbolName: "arrow.left.arrow.right") { [unowned self] in
                    self.invertStops()
                }
                .with(\.toolTip, "Invert")
                .with(\.controlSize, .small),
            ]),
            insets: .init(vertical: 0, horizontal: 7)
        )
    }()

    private lazy var slider: BaseSliderView = {
        BaseSliderView(value: self.value)
            .with(
                \.onChange,
                { [unowned self] change in
                    self.value = change.newValue
                    self.onChange?(change)
                }
            )
            .with(
                \.addStopAt,
                { [unowned self] pos in
                    self.addStop(at: pos)
                }
            )
            .with(
                \.removeStop,
                { [unowned self] index in
                    self.removeStop(index: index)
                }
            )
    }()

    private lazy var colorPicker: Padded<ColorPicker> = {
        Padded(
            ColorPicker(.systemBlue)
                .onChange({ [unowned self] color in
                    self.onColorPickerChange(color)
                }),
            insets: .init(vertical: 0, horizontal: 7)
        )
    }()

    public init(_ value: GradientData) {
        self.value = value

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        self.setupView()
        self.setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview()
    }

    private func setupObservers() {
        self.slider.$selectedThumbIndex.sink { [unowned self] maybeIndex in
            if let index = maybeIndex, let color = self.value.stops[tryGetAt: index]?.color {
                self.colorPicker.view.color = color.nsColor
            }
        }.store(in: &self.cancellables)
    }

    private func update() {
        self.slider.value = self.value

        if let index = self.slider.selectedThumbIndex,
            let color = self.value.stops[tryGetAt: index]?.color
        {
            let nsColor = color.nsColor
            if self.colorPicker.view.color != nsColor {
                self.colorPicker.view.color = nsColor
            }
        }

        if self.value.interpolation.rawValue != self.interpPickerView.selected {
            self.interpPickerView.selected = self.value.interpolation.rawValue
        }

        if let controller = self.noisePopoverController {
            if controller.value != self.value.noiseAmount {
                controller.value = self.value.noiseAmount
            }
        }
    }

    func noiseButtonClick() {
        // guard let button = self.button else { return }
        let ctrl = NoisePopoverController(self.value.noiseAmount) { [unowned self] newValue in
            self.setNoiseAmount(newValue)
        }
        ctrl.preferredContentSize = .init(width: 200, height: 28)
        self.window?.contentViewController?.present(
            ctrl,
            asPopoverRelativeTo: self.noiseButton.bounds,
            of: self.noiseButton,
            preferredEdge: .maxY,
            behavior: .transient
        )
        self.noisePopoverController = ctrl
    }

    func setNoiseAmount(_ amount: Double) {
        if amount != self.value.noiseAmount {
            let oldValue = self.value
            self.value.noiseAmount = amount
            self.onChange?(.init(newValue: self.value, oldValue: oldValue, commit: true))
        }
    }

    func invertStops() {
        let oldValue = self.value
        self.value.stops = self.value.stops.reversed().map({ $0.with(\.position, 1.0 - $0.position) })
        if self.value != oldValue {
            self.onChange?(.init(newValue: self.value, oldValue: oldValue, commit: true))
        }
    }

    func removeStop() {
        if self.value.stops.count <= 2 { return }
        guard let index = self.slider.selectedThumbIndex else { return }
        self.removeStop(index: index)
    }

    func removeStop(index: Int) {
        let oldValue = self.value
        self.value.stops.remove(at: index)
        self.onChange?(.init(newValue: self.value, oldValue: oldValue, commit: true))
        if !self.value.stops.indices.contains(index) {
            self.slider.selectedThumbIndex = self.value.stops.indices.first!
        } else {
            self.slider.selectedThumbIndex = index
        }
    }

    func addStop() {
        let gap = self.value.largestGap()
        let index = gap.index
        let pos = gap.range.mid

        self.addStop(at: pos, index: index)
    }

    func addStop(at pos: CGFloat, index: Int? = nil) {
        let color = {
            if let bitmapRep = self.slider.gradientBarView.bitmapRep,
                let nsColor = bitmapRep.colorAt(x: Int(pos * Double(self.slider.gradientBarView.bitmapWidth)), y: 0),
                let c = Color4(nsColor: nsColor)
            {
                return c
            } else {
                return .black
            }
        }()

        let index = index ?? self.value.indexForAddingStop(at: pos)

        let oldValue = self.value
        self.value.stops.insert(.init(position: pos, color: color), at: index)
        self.onChange?(.init(newValue: self.value, oldValue: oldValue, commit: true))
        self.slider.selectedThumbIndex = index
    }

    func onColorPickerChange(_ color: XColor) {
        if let index = self.slider.selectedThumbIndex, let c = Color4(nsColor: color) {
            let oldValue = self.value
            self.value.stops[index].color = c
            self.onChange?(.init(newValue: self.value, oldValue: oldValue, commit: true))
        }
    }
}

fileprivate final class BaseSliderView: XView, WithRef {

    public var value: GradientData {
        didSet {
            if self.value != oldValue {
                self.gradientBarView.data = self.value
                self.updateThumbs()
                self.setNeedsLayout()
            }
        }
    }

    public var onChange: ((GradientDataEditor.Change) -> ())?
    public var addStopAt: ((CGFloat) -> ())?
    public var removeStop: ((Int) -> ())?

    fileprivate var thumbs: [ThumbView] = []

    @PublishedEx fileprivate var selectedThumbIndex: Int? {
        didSet {
            for (index, thumb) in self.thumbs.enumerated() {
                thumb.selected = self.selectedThumbIndex == index
            }
        }
    }

    fileprivate lazy var gradientBarView: GradientBarView = {
        GradientBarView(self.value)
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    public override var intrinsicContentSize: NSSize {
        .init(width: Self.noIntrinsicMetric, height: 28 + 17 * 2)
    }

    public init(value: GradientData) {
        self.value = value

        super.init(frame: .zero)

        self.wantsLayer = true
        self.clipsToBounds = false

        self.setupView()
        self.setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.addSubview(self.gradientBarView)
        NSLayoutConstraint.activate([
            // self.gradientBarView.widthAnchor.constraint(equalTo: self.widthAnchor),
            self.gradientBarView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 7),
            self.gradientBarView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -7),
            self.gradientBarView.topAnchor.constraint(equalTo: self.topAnchor, constant: 17),
            self.gradientBarView.heightAnchor.constraint(equalToConstant: 28),
        ])

        self.reloadThumbs()
    }

    func updateThumbs() {
        if self.value.stops.count != self.thumbs.count {
            self.reloadThumbs()
            return
        }

        for (stop, thumb) in zip(self.value.stops, self.thumbs) {
            if stop.color != thumb.color {
                thumb.color = stop.color
            }
        }
    }

    private func reloadThumbs() {
        self.thumbs.forEach({ $0.removeFromSuperview() })
        self.thumbs = []

        var position: ThumbView.Position = .bottom
        for (index, stop) in self.value.stops.enumerated() {
            let view = ThumbView(stop.color, position: position, selected: false)
                .with(
                    \.onClick,
                    { [unowned self] in
                        self.selectedThumbIndex = index
                    }
                )
            position.toggle()
            self.thumbs.append(view)
            self.addSubview(view)
        }

        if self.selectedThumbIndex == nil {
            self.selectedThumbIndex = 0
        }
    }

    enum ThumbDragState {
        case idle
        case dragging(Int, CGFloat, GradientData)
    }

    private func setupGestures() {
        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)

        let pressGesture = NSPressGestureRecognizer(target: self, action: #selector(Self.pressGestureHandler(_:)))
        pressGesture.delegate = self
        pressGesture.minimumPressDuration = 0
        self.addGestureRecognizer(pressGesture)

        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(Self.clickGestureHandler(_:)))
        clickGesture.delegate = self
        clickGesture.numberOfClicksRequired = 2
        self.addGestureRecognizer(clickGesture)
    }

    var thumbDragState: ThumbDragState = .idle

    @objc func clickGestureHandler(_ gesture: NSClickGestureRecognizer) {
        let loc = self.gradientBarView.convert(gesture.location(in: nil), from: nil)
        if self.gradientBarView.bounds.contains(loc) {
            let pos = loc.x / self.gradientBarView.bounds.width
            self.addStopAt?(pos)
        }
    }

    @objc
    func pressGestureHandler(_ gesture: NSPressGestureRecognizer) {
        if gesture.state == .began {
            if let index = self.thumbHitTest(self.convert(gesture.location(in: nil), from: nil)) {
                self.selectedThumbIndex = index
            }
        }
    }

    func thumbHitTest(_ loc: CGPoint) -> Int? {
        for (index, thumb) in self.thumbs.enumerated() {
            if thumb.frame.contains(loc) {
                return index
            }
        }
        return nil
    }

    @objc
    func panGestureHandler(_ gesture: NSPanGestureRecognizer) {

        let loc = self.convert(gesture.location(in: nil), from: nil)
        let t = gesture.translation(in: nil)

        switch gesture.state {
        case .began:
            self.thumbDragState = .idle
            if let index = self.thumbHitTest(loc), let thumb = self.thumbs[tryGetAt: index] {
                self.thumbDragState = .dragging(index, thumb.frame.minX, self.value)
                self.selectedThumbIndex = index
            }
        case .changed:
            switch self.thumbDragState {
            case .idle: break
            case .dragging(let thumbIndex, let startX, _):

                let newThumbPos = startX + t.x
                var newStopPos: CGFloat {
                    var pos = self.convert(thumbToStopPosition: newThumbPos).clamped(to: 0...1)

                    if let prev = self.value.stops[tryGetAt: thumbIndex - 1]?.position {
                        if pos < prev {
                            pos = prev
                        }
                    }

                    if let next = self.value.stops[tryGetAt: thumbIndex + 1]?.position {
                        if pos > next {
                            pos = next
                        }
                    }

                    return pos
                }

                self.setValue(
                    self.value.with(\.stops[thumbIndex].position, newStopPos),
                    commit: false
                )
            }
        case .ended:
            switch self.thumbDragState {
            case .dragging(_, _, let startValue):
                self.setValue(self.value, oldValue: startValue, commit: true)
            default: break
            }
            self.thumbDragState = .idle
        case .cancelled:
            switch self.thumbDragState {
            case .dragging(_, _, let startValue):
                self.setValue(startValue, commit: false)
            default: break
            }
            self.thumbDragState = .idle
        default:
            self.thumbDragState = .idle
        }
    }

    private func setValue(_ value: GradientData, oldValue: GradientData? = nil, commit: Bool) {
        let oldValue = oldValue ?? self.value
        self.value = value
        self.onChange?(.init(newValue: value, oldValue: oldValue, commit: commit))
    }

    func convert(stopToThumbPosition pos: CGFloat) -> CGFloat {
        pos * (self.bounds.width - 14)
    }

    func convert(thumbToStopPosition pos: CGFloat) -> CGFloat {
        pos / (self.bounds.width - 14)
    }

    public override func layout() {
        super.layout()
        for (index, stop) in self.value.stops.enumerated() {
            guard let view = self.thumbs[tryGetAt: index] else { continue }
            let pad = 0.0
            let pos = pad + stop.position * (self.bounds.width - 14 - 2 * pad)
            let y =
                switch view.position {
                case .bottom: 0.0
                case .top: 45.0 - 28
                }
            view.frame = .init(x: pos, y: y, width: 14, height: 45)
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        for (index, thumb) in self.thumbs.enumerated() {
            let loc = thumb.convert(event.locationInWindow, from: nil)
            if thumb.bounds.contains(loc) {
                let menu = NSMenu()
                menu.items = [
                    ClosureMenuItem(title: "Delete stop") { [unowned self] in self.removeStop?(index) }
                ]
                NSMenu.popUpContextMenu(menu, with: event, for: thumb)
                return
            }
        }

        let loc = self.gradientBarView.convert(event.locationInWindow, from: nil)
        if self.gradientBarView.bounds.contains(loc) {
            let x = loc.x / self.gradientBarView.bounds.width
            let menu = NSMenu()
            menu.items = [
                ClosureMenuItem(title: "Add stop") { [unowned self] in self.addStopAt?(x) }
            ]
            NSMenu.popUpContextMenu(menu, with: event, for: self.gradientBarView)
        }
    }
}

extension BaseSliderView: NSGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: NSGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSGestureRecognizer
    ) -> Bool {
        true
    }
}

extension Color4 {
    var cgColor: CGColor {
        .init(red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
    }
}

fileprivate final class GradientBarView: XView, WithRef {

    var data: GradientData {
        didSet {
            self.setNeedsDisplay()
        }
    }

    let context: CIContext
    var bitmapRep: NSBitmapImageRep?
    var bitmapWidth: Int = 0
    var lastDrawSize: CGSize? = nil

    lazy var imageView: XImageView = {
        let view = XImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow - 10, for: .horizontal)
        view.imageScaling = .scaleAxesIndependently
        return view
    }()

    lazy var checkerView: XImageView = {
        let view = XImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultLow - 10, for: .horizontal)
        view.imageScaling = .scaleAxesIndependently
        return view
    }()

    init(_ data: GradientData) {
        self.context = CIContext()
        self.data = data
        super.init(frame: .zero)

        self.addSubview(self.checkerView)
        self.checkerView.constraintToFillSuperview()

        self.addSubview(self.imageView)
        self.imageView.constraintToFillSuperview()
    }

    func drawCheckerboard() {
        if self.lastDrawSize == self.bounds.size { return }
        self.lastDrawSize = self.bounds.size
        self.checkerView.image = .checkerboard(
            self.context,
            size: self.bounds.size
        )
    }

    func drawGradient() {
        let scale = self.window?.backingScaleFactor ?? 2.0
        let filter = GradientFilter(self.data, p0: .init(x: 0, y: 0), p1: .init(x: scale * self.bounds.width, y: 0))
        let ciImage = filter.outputImage!.cropped(
            to: .init(x: 0, y: 0, width: scale * self.bounds.width, height: scale * self.bounds.height)
        )
        let cgImage = context.createCGImage(
            ciImage,
            from: ciImage.extent,
            format: .RGBA8,
            colorSpace: nil,
            deferred: false,
            calculateHDRStats: false
        )!
        let nsImage = NSImage(cgImage: cgImage, size: ciImage.extent.size)
        self.imageView.image = nsImage
        self.withLayer({ layer in
            layer.cornerRadius = 5
            layer.borderWidth = 1
            layer.borderColor = .init(gray: self.effectiveAppearance.isDarkMode ? 1.0 : 0.0, alpha: 0.1)
        })

        self.bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        self.bitmapWidth = cgImage.width
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.drawGradient()
        self.drawCheckerboard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate final class ThumbView: XView, WithRef {

    var color: Color4 = .red {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var selected: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var position: Position = .bottom {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var onClick: (() -> ())?

    enum Position {
        case top
        case bottom

        mutating func toggle() {
            self =
                switch self {
                case .top: .bottom
                case .bottom: .top
                }
        }
    }

    private var lineWidth: CGFloat {
        self.selected ? 2.0 : 1.0
    }

    lazy var bgLayer: CALayer = {
        let layer = CALayer()
        return layer
    }()

    lazy var bgLayerMask: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()

    lazy var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()

    lazy var borderShapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()

    lazy var shadowShapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()

    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        return layer
    }()

    override var isOpaque: Bool { false }

    init(_ color: Color4, position: Position = .bottom, selected: Bool = false) {
        self.color = color
        self.selected = selected
        self.position = position

        super.init(frame: .zero)

        self.wantsLayer = true

        self.withLayer({ layer in
            layer.addSublayer(self.bgLayer)
            layer.addSublayer(self.shapeLayer)
            layer.addSublayer(self.shadowShapeLayer)
            layer.addSublayer(self.borderShapeLayer)
            layer.masksToBounds = false
            for subLayer in [self.shapeLayer, self.shadowShapeLayer, self.borderShapeLayer] {
                subLayer.frame = subLayer.bounds
                subLayer.autoresizingMask = [.layerHeightSizable, .layerHeightSizable]
                subLayer.isOpaque = false
            }

            layer.addSublayer(self.gradientLayer)
            self.gradientLayer.frame = .init(x: 6.5, y: 14, width: 1, height: 45 - 14)
            layer.isOpaque = false
        })

        self.shadowShapeLayer.filters = [
            {
                let filter = CIFilter.gaussianBlur()
                filter.radius = 1.0
                return filter
            }()
        ]

        self.shapeLayer.delegate = self
    }

    override var intrinsicContentSize: NSSize {
        .init(width: 14, height: 45)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let layer else { return }

        self.bgLayerMask.frame = layer.bounds
        self.bgLayer.frame = layer.bounds
        self.bgLayer.backgroundColor = .blue
        self.bgLayer.mask = self.bgLayerMask

        if self.bgLayer.contents == nil {
            self.bgLayer.contents = NSImage.checkerboard(nil, size: self.bounds.size)
        }

        self.shapeLayer.fillColor = self.color.cgColor

        self.borderShapeLayer.strokeColor = .white
        self.borderShapeLayer.fillColor = .clear
        self.borderShapeLayer.lineWidth = self.lineWidth

        self.shadowShapeLayer.strokeColor = .init(gray: 0.1, alpha: 0.45)
        self.shadowShapeLayer.fillColor = .clear
        self.shadowShapeLayer.lineWidth = self.lineWidth + 1
        //
        let path = CGMutablePath()
        path.addPath(
            .init(
                ellipseIn: {
                    switch self.position {
                    case .bottom:
                        .init(origin: .zero, size: .init(width: 14, height: 14))
                    case .top:
                        .init(origin: .init(x: 0, y: 45 - 14), size: .init(width: 14, height: 14))
                    }
                }(),
                transform: nil
            )
        )

        self.bgLayerMask.path = path
        self.shapeLayer.path = path
        self.borderShapeLayer.path = path
        self.shadowShapeLayer.path = path

        self.gradientLayer.frame =
            switch self.position {
            case .bottom: .init(x: 6.5, y: 14, width: 1, height: 45 - 14)
            case .top: .init(x: 6.5, y: 0, width: 1, height: 45 - 14)
            }
        self.gradientLayer.colors =
            switch self.position {
            case .bottom:
                [
                    CGColor(gray: 1.0, alpha: 0.0),
                    CGColor(gray: 1.0, alpha: 0.01),
                    CGColor(gray: 1.0, alpha: 0.2),
                    CGColor.white,
                ].reversed()
            case .top:
                [
                    CGColor(gray: 1.0, alpha: 0.0),
                    CGColor(gray: 1.0, alpha: 0.01),
                    CGColor(gray: 1.0, alpha: 0.2),
                    CGColor.white,
                ]
            }
    }
}

extension ThumbView: CALayerDelegate {
    func action(for layer: CALayer, forKey event: String) -> (any CAAction)? {
        if event == "fillColor" {
            return NSNull()
        } else {
            return nil
        }
    }
}

extension ClosedRange<Double> {
    var mid: Double {
        self.lowerBound + 0.5 * self.span
    }
}

extension GradientData {
    struct Gap {
        var index: Int
        var range: ClosedRange<Double>
    }

    func largestGap() -> Gap {
        var prev: CGFloat = 0.0
        var currentLargestDelta: CGFloat = 0.0
        var index: Int = 0
        for i in 0...self.stops.count {
            let delta =
                {
                    if i < self.stops.count {
                        let delta = self.stops[i].position - prev
                        prev = self.stops[i].position
                        return delta
                    } else {
                        let delta = 1.0 - self.stops.last!.position
                        return delta
                    }
                }()

            if delta > currentLargestDelta {
                currentLargestDelta = delta
                index = i
            }
        }

        let range: ClosedRange<Double> = {
            if index == self.stops.count {
                self.stops.last!.position...1.0
            } else if index == 0 {
                0.0...self.stops.first!.position
            } else {
                self.stops[index - 1].position...self.stops[index].position
            }
        }()

        return .init(index: index, range: range)
    }

    func indexForAddingStop(at pos: Double) -> Int {
        for (index, stop) in self.stops.enumerated() {
            if pos <= stop.position {
                return index
            }
        }
        return self.stops.count
    }
}

class NoisePopoverController: NSViewController {

    var value: Double = 0.0 {
        didSet {
            if self.slider.doubleValue != value {
                self.slider.doubleValue = value
            }
        }
    }

    var onChange: ((Double) -> ())?

    lazy var slider: NSSlider = {
        let slider = NSSlider(
            value: self.value,
            minValue: 0.0,
            maxValue: 1.0,
            target: self,
            action: #selector(self.sliderHandler)
        )
        slider.controlSize = .mini
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    init(_ value: Double, onChange: ((Double) -> ())? = nil) {
        self.value = value
        self.onChange = onChange
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func sliderHandler() {
        if slider.doubleValue != self.value {
            self.value = slider.doubleValue
            self.onChange?(slider.doubleValue)
        }
    }

    override func viewDidLoad() {
        self.view.addSubview(self.slider)
        self.slider.constraintToFillSuperview(insets: .init(vertical: 8, horizontal: 8))
    }
}

#Preview {
    GradientDataEditor(
        .init([
            .init(position: 0.0, color: .white),
            .init(position: 0.5, color: .init(red: 0.6, green: 0.6, blue: 0.8, alpha: 1.0)),
            .init(position: 1.0, color: .black),
        ])
    )
    .with(\.onChange, { change in print("change: \(change)") })
    .constrainingWidth(toConstant: 256)
}

#Preview {
    BaseSliderView(
        value: .init([
            .init(position: 0.0, color: .white),
            .init(position: 0.5, color: .init(red: 0.6, green: 0.6, blue: 0.8, alpha: 1.0)),
            .init(position: 1.0, color: .black),
        ])
    )
    // .constrainingWidth(toConstant: 256)
    .withBorder(.systemRed.withAlphaComponent(0.2), width: 1)
}

#Preview {
    GradientBarView(
        .init([
            .init(position: 0.0, color: .init(red: 0.2, green: 0.1, blue: 0.1, alpha: 1.0)),
            .init(position: 1.0, color: .init(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0)),
        ])
    )
    .constrainingWidth(toConstant: 256)
    .constrainingHeight(toConstant: 28)
}

#Preview {
    HStack(views: [
        ThumbView(.red)
            .constrainingWidth(toConstant: 14)
            .constrainingHeight(toConstant: 45),
        ThumbView(.red, selected: true)
            .constrainingWidth(toConstant: 14)
            .constrainingHeight(toConstant: 45),
        ThumbView(.red, position: .top)
            .constrainingWidth(toConstant: 14)
            .constrainingHeight(toConstant: 45),
        ThumbView(.red, position: .top, selected: true)
            .constrainingWidth(toConstant: 14)
            .constrainingHeight(toConstant: 45),
    ])
}
