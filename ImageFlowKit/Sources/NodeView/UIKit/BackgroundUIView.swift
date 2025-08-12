//
//  BackgroundUIView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 11/08/25.
//

import ColorUtils
import Design
import Easing
import PlatformUtils
import SwiftUI
import CanvasView

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

class BackgroundUIView: PlatformView {

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

    init(frame frameRect: CGRect = .zero, color: DynamicColor = .blue) {
        self.color = color
        super.init(frame: frameRect)

        self.setWantsLayer()
        self.layer().insertSublayer(self.gradientLayer, at: 0)
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

    override func draw(_ rect: CGRect) {
        self.draw()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
