import Combine
import Helpers
import XKit

public final class ColorPicker: XView, Rx, WithRef {
    @PublishedEx public var color: XColor = .red {
        didSet {
            if self.color != oldValue {
                self.update()
            }
        }
    }

    // NOTE: Not used on macOS
    public var commitedColor: NSColor = .red

    public var isLocked: Bool = false {
        didSet {
            if self.isLocked != oldValue {
                if self.isLocked {
                    self.animBorder(to: self.borderWidth)
                }
            }
        }
    }

    public var showsAlpha: Bool = true

    public var disabled: Bool {
        get { self.isLocked }
        set { self.isLocked = newValue }
    }

    public var cancellables: Set<AnyCancellable> = []

    private var _onChange: ((XColor) -> ())?

    private var trackingArea: NSTrackingArea?

    private var token: ColorPanelManager.Token?

    private let checkerBoardLayer = CALayer()
    private let colorLayer = CALayer()
    private let borderLayer = CALayer()
    private var lastDrawSize: CGSize?

    var height: CGFloat = 24 { didSet { self.invalidateIntrinsicContentSize() } }
    var width: CGFloat = XView.noIntrinsicMetric { didSet { self.invalidateIntrinsicContentSize() } }
    let radius: CGFloat = 6
    let borderWidth: CGFloat = 2
    let borderWidthHover: CGFloat = 4
    let borderColor: DynamicColor = .init(light: .init(white: 0.8, alpha: 1), dark: .init(white: 0.32, alpha: 1.0))

    public override var intrinsicContentSize: NSSize {
        .init(width: self.width, height: self.height)
    }

    public init(_ color: XColor) {
        self.color = color

        super.init(frame: .zero)

        self.withLayer { layer in

            layer.cornerCurve = .continuous
            layer.cornerRadius = self.radius
            layer.masksToBounds = true

            self.borderLayer.cornerCurve = .continuous
            self.borderLayer.cornerRadius = self.radius
            self.borderLayer.borderWidth = self.borderWidth

            layer.addSublayer(self.checkerBoardLayer)
            layer.addSublayer(self.colorLayer)
            layer.addSublayer(self.borderLayer)
        }

        self.colorLayer.delegate = self
        self.borderLayer.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func onChange(_ perform: @escaping (XColor) -> ()) -> Self {
        self._onChange = perform
        return self
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        if self.lastDrawSize != self.bounds.size {
            self.checkerBoardLayer.contents = NSImage.checkerboard(nil, size: self.bounds.size)
            self.lastDrawSize = self.bounds.size
        }

        self.withLayer { layer in
            self.checkerBoardLayer.frame = layer.bounds.insetBy(dx: 0.5, dy: 0.5)
            self.colorLayer.frame = layer.bounds
            self.borderLayer.frame = layer.bounds

            self.colorLayer.backgroundColor = self.color.cgColor

            let lum = max(self.color.redComponent, max(self.color.blueComponent, self.color.greenComponent))

            if self.effectiveAppearance.isDarkMode {
                self.borderLayer.borderColor =
                    .init(
                        gray: (1.0 - lum),
                        alpha: 0.25
                    )
            } else {
                let min = 0.16
                let max = 0.45
                self.borderLayer.borderColor =
                    .init(
                        gray: (1.0 - lum),
                        alpha: (min - max) * lum + max,
                    )
            }
        }
    }

    public override func updateTrackingAreas() {
        super.updateTrackingAreas()

        // Remove the old tracking area
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }

        // Create a new tracking area
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeAlways,
            .inVisibleRect,
        ]
        trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: options,
            owner: self,
            userInfo: nil
        )

        // Add the new tracking area
        addTrackingArea(trackingArea!)
    }

    public override func mouseEntered(with event: NSEvent) {
        guard !self.isLocked else { return }

        self.animBorder(to: self.borderWidthHover)
    }

    public override func mouseExited(with event: NSEvent) {
        guard !self.isLocked else { return }

        self.animBorder(to: self.borderWidth)
    }

    private var isMouseDown: Bool = true

    public override func mouseDown(with event: NSEvent) {
        guard !self.isLocked else { return }

        self.isMouseDown = true
        self.animBorder(to: 6, duration: 0.1)
    }

    public override func mouseUp(with event: NSEvent) {
        guard !self.isLocked else { return }

        let pos = self.convert(event.locationInWindow, from: nil)
        if self.isMouseDown && self.bounds.contains(pos) {
            self.clickHandler()
            self.animBorder(to: self.borderWidthHover, duration: 0.1)
        } else if self.isMouseDown {
            self.animBorder(to: self.borderWidth, duration: 0.2)
        }
        self.isMouseDown = false
    }

    @objc
    func clickHandler() {
        guard !self.isLocked else { return }

        self.token = ColorPanelManager.shared.open(
            initialColor: self.color,
            showsAlpha: self.showsAlpha,
            onChange: { [weak self] newValue in
                self?.color = newValue
                self?._onChange?(newValue)
            }
        )
    }

    func animBorder(to value: CGFloat, duration: CGFloat = 0.2) {
        let anim = CABasicAnimation()
        anim.timingFunction = .init(name: .easeInEaseOut)
        anim.fromValue = self.borderLayer.borderWidth
        anim.toValue = value
        anim.duration = CFTimeInterval(duration)
        self.borderLayer.add(anim, forKey: "borderWidth")
        self.borderLayer.borderWidth = value
    }

    func update() {
        self.setNeedsDisplay()
    }
}

extension ColorPicker: CALayerDelegate {
    public func action(for layer: CALayer, forKey event: String) -> (any CAAction)? {
        return NSNull()
    }
}

#if os(macOS)

import AppKit

@MainActor
class ColorPanelManager {
    private var onChange: ((NSColor) -> ())?
    private var currentToken: UInt = 0

    typealias Token = UInt

    static let shared: ColorPanelManager = .init()

    private lazy var panel: NSColorPanel = {
        let panel = NSColorPanel.shared
        panel.setTarget(self)
        panel.setAction(#selector(Self.onPanelColorChanged(_:)))
        return panel
    }()

    public func open(
        initialColor color: NSColor,
        showsAlpha: Bool = true,
        onChange: @escaping (NSColor) -> (),
    ) -> Token {
        self.panel.setTarget(nil)
        self.panel.setAction(nil)
        self.panel.color = color
        self.panel.showsAlpha = showsAlpha
        self.panel.setTarget(self)
        self.panel.setAction(#selector(Self.onPanelColorChanged(_:)))
        self.panel.orderFront(nil)
        self.panel.isContinuous = true

        self.onChange = onChange

        self.nextToken()
        return self.currentToken
    }

    private func nextToken() {
        self.currentToken = self.currentToken &+ 1
    }

    func setColor(color: NSColor, token: Token) {
        if token == self.currentToken {
            self.panel.color = color
        }
    }

    @objc
    private func onPanelColorChanged(_ panel: NSColorPanel) {
        self.onChange?(panel.color)
    }
}

#endif

#Preview {
    ColorPicker(.red)
        .constrainingWidth(toConstant: 300)
}
