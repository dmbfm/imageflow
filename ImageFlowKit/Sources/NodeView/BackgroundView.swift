import CanvasView
import Design
import Helpers
import Logging
import SwiftUI

import struct Helpers.ShadowStyle

final class BackgroundView: PlatformView {

    var style: BackgroundViewStyle {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var onEvent: ((Event) -> ())?

    enum Event {
        case tap
        case drag(CanvasNodeDragGesture)
    }

    var gradientLayer: CAGradientLayer = CAGradientLayer()

    init(style: BackgroundViewStyle = .default) {
        self.style = style

        super.init(frame: .zero)

        self.platformInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Platform: macOS

    #if os(macOS)

    var gradientChannelMask: HSL.ChannelMask {
        if self.effectiveAppearance.isDarkMode {
            [.lightness, .saturation]
        } else {
            [.lightness]
        }
    }

    private func platformInit() {
        let borderAnim = CABasicAnimation()
        borderAnim.timingFunction = .init(name: .easeInEaseOut)
        self.gradientLayer.actions = [
            "borderColor": borderAnim,
            "borderWidth": borderAnim,
        ]

        self.wantsLayer = true
        self.layer?.insertSublayer(self.gradientLayer, at: 0)
        self.shadow = NSShadow()
        self.wantsLayer = true
        self.layer?.shadowColor = self.style.shadow.color.cgColor
        self.layer?.shadowRadius = self.style.shadow.radius
        self.layer?.shadowOpacity = Float(self.style.shadow.opacity)
        self.layer?.shadowOffset = self.style.shadow.offset

        let clickGR = NSClickGestureRecognizer(target: self, action: #selector(Self.onClickGesture(_:)))
        clickGR.delegate = self
        self.addGestureRecognizer(clickGR)

        let panGR = NSPanGestureRecognizer(target: self, action: #selector(Self.onPanGesture(_:)))
        panGR.delegate = self
        self.addGestureRecognizer(panGR)
    }

    @objc
    func onClickGesture(_ gesture: NSClickGestureRecognizer) {
        self.onEvent?(.tap)
    }

    @objc
    func onPanGesture(_ gesture: NSPanGestureRecognizer) {
        let t = gesture.translation(in: nil)
        self.onEvent?(.drag(.init(phase: .init(gestureRecognizerState: gesture.state), dx: t.x, dy: -t.y)))
        gesture.setTranslation(.zero, in: nil)
    }

    override var isFlipped: Bool {
        true
    }

    public override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.gradientLayer.frame = self.bounds
        CATransaction.commit()
    }

    public func showBorder() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(self.style.borderAnimationDuration)
        self.gradientLayer.borderWidth = self.style.selectedBorderWidth
        self.gradientLayer.borderColor = self.style.selectedBorderColor.cgColor
        CATransaction.commit()
    }

    public func hideBorder() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(self.style.borderAnimationDuration)
        self.gradientLayer.borderWidth = 0.0
        CATransaction.commit()
    }

    override func draw(_ dirtyRect: NSRect) {
        self.draw()
    }
    #endif

    // MARK: - Platform: iOS

    #if os(iOS)
    private func platformInit() {
        self.setWantsLayer()
        self.layer().insertSublayer(self.gradientLayer, at: 0)
        self.layer.shadowColor = self.style.shadow.color.cgColor
        self.layer.shadowOpacity = Float(self.style.shadow.opacity)
        self.layer.shadowRadius = self.style.shadow.radius
        self.layer.shadowOffset = self.style.shadow.offset
        self.gradientLayer.frame = self.bounds

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Self.tapGestureHandler))
        self.addGestureRecognizer(tapGesture)

        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.panGestureHangler(_:)))
        self.addGestureRecognizer(dragGesture)
    }

    @objc
    func tapGestureHandler() {
        self.onEvent?(.tap)
    }

    @objc
    func panGestureHangler(_ gesture: UIPanGestureRecognizer) {
        let t = gesture.translation(in: nil)
        let phase: GesturePhase = .init(gestureRecognizerState: gesture.state)
        self.onEvent?(.drag(.init(phase: phase, dx: t.x, dy: t.y)))
        gesture.setTranslation(.zero, in: nil)
    }

    override func layoutSublayers(of layer: CALayer) {
        if layer == self.layer {
            self.gradientLayer.frame = self.bounds
        }
    }

    var gradientChannelMask: HSL.ChannelMask {
        if self.traitCollection.userInterfaceStyle == .dark {
            [.lightness, .saturation]
        } else {
            [.lightness]
        }
    }

    func showBorder() {
        self.layer.borderWidth = self.style.selectedBorderWidth
        self.layer.borderColor = self.style.selectedBorderColor.cgColor
    }

    func hideBorder() {
        self.layer.borderWidth = 0
    }

    override func draw(_ rect: CGRect) {
        self.draw()
    }
    #endif

    func draw() {
        self.layer().cornerRadius = self.style.cornerRadius
        self.gradientLayer.cornerRadius = self.style.cornerRadius
        self.updateGradientColor(self.style.color.cgColor)
    }

    func updateGradientColor(_ color: CGColor) {
        self.gradientLayer.colors = CAGradientLayer.colors(
            hslGradientStart: color,
            end: Colors.cardBackground.cgColor,
            channelMask: self.gradientChannelMask,
            curve: .cubic,
            stops: 10
        )
        self.gradientLayer.startPoint = CGPointMake(0, -10.0 / self.bounds.height)
        self.gradientLayer.endPoint = CGPointMake(0, self.style.gradientHeight / self.bounds.height)
    }
}

#if os(macOS)
extension BackgroundView: NSGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: NSGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSGestureRecognizer
    ) -> Bool {
        true
    }
}
#endif

public struct BackgroundViewStyle: Sendable, Hashable, With {
    public var cornerRadius: CGFloat
    public var color: PlatformColor
    public var shadow: ShadowStyle
    public var gradientHeight: CGFloat
    public var borderAnimationDuration: CGFloat
    public var selectedBorderWidth: CGFloat
    public var selectedBorderColor: PlatformColor

    public static var `default`: Self {
        .init(
            cornerRadius: 10,
            color: .systemBlue,
            shadow: .init(
                radius: 4,
                color: .init(white: 0, alpha: 0.4),
                opacity: 1,
                offset: .init(width: 0, height: 2)
            ),
            gradientHeight: 50,
            borderAnimationDuration: 0.08,
            selectedBorderWidth: 2,
            selectedBorderColor: .systemBlue,
        )
    }
}

extension CAGradientLayer {
    convenience init?(
        hslGradientStart start: CGColor,
        end: CGColor,
        channelMask: HSL.ChannelMask,
        curve: EasingCurve,
        stops: Int
    ) {
        guard
            let colors = Self.colors(
                hslGradientStart: start,
                end: end,
                channelMask: channelMask,
                curve: curve,
                stops: stops
            )
        else {
            return nil
        }
        self.init()
        self.colors = colors
    }

    public static func colors(
        hslGradientStart start: CGColor,
        end: CGColor,
        channelMask: HSL.ChannelMask,
        curve: EasingCurve,
        stops: Int
    ) -> [CGColor]? {

        guard let start = HSL(cgColor: start), let end = HSL(cgColor: end) else {
            return nil
        }

        return start.gradientColors(to: end, channelMask: channelMask, curve: curve, stops: stops).map { $0.cgColor }
    }
}

extension BackgroundView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> some PlatformView {
            let view = BackgroundView()
            view.clipsToBounds = false
            view.onEvent = { log("event: \($0)") }
            return view
        }

        func updateView(_ view: ViewType, context: Context) {

        }
    }
}

#Preview {
    VStack {
        BackgroundView.Preview()
            .frame(width: 150, height: 200)
    }
    .padding(50)
}
