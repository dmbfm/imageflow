//
//  BackgroundNSView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 13/08/25.
//

#if canImport(AppKit)

import AppKit
import ColorUtils
import PlatformUtils
import CanvasView

public final class BackgroundNSView: NSView {

    public var color: DynamicColor = .blue {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var gradientHeight: CGFloat = 50 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var cornerRadius: CGFloat = 10 {
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

    var gradientChannelMask: HSL.ChannelMask {
        if self.effectiveAppearance.isDarkMode {
            [.lightness, .saturation]
        } else {
            [.lightness]
        }
    }

    init(frame: CGRect = .zero, color: DynamicColor = .blue) {
        self.color = color
        super.init(frame: frame)

        self.wantsLayer = true
        self.layer?.insertSublayer(self.gradientLayer, at: 0)

        let clickGR = NSClickGestureRecognizer(target: self, action: #selector(Self.onClickGesture(_:)))
        self.addGestureRecognizer(clickGR)

        let panGR = NSPanGestureRecognizer(target: self, action: #selector(Self.onPanGesture(_:)))
        self.addGestureRecognizer(panGR)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    @objc
    func onClickGesture(_ gesture: NSClickGestureRecognizer) {
        self.onEvent?(.tap)
    }

    @objc
    func onPanGesture(_ gesture: NSPanGestureRecognizer) {
        let t = gesture.translation(in: nil)
        self.onEvent?(.drag(.init(phase: .init(gestureRecognizerState: gesture.state), dx: t.x, dy: t.y)))
        gesture.setTranslation(.zero, in: nil)
    }

    public override var isFlipped: Bool {
        true
    }

    public override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.gradientLayer.frame = self.bounds
        CATransaction.commit()
    }

    public override func draw(_ dirtyRect: NSRect) {
        self.draw()
    }
}

#endif
