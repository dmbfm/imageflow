import ColorUtils
import Design
import Easing
import PlatformUtils
import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

class BackgroundView: PlatformView {

    public var color: DynamicColor = .systemBlue {
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

    private var gradientLayer: CAGradientLayer = CAGradientLayer()

    init(frame frameRect: CGRect = .zero, color: DynamicColor = .systemBlue) {
        self.color = color
        super.init(frame: frameRect)

        self.setWantsLayer()
        self.layer().insertSublayer(self.gradientLayer, at: 0)
        self.gradientLayer.frame = self.bounds
        #if os(macOS)
        self.gradientLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        #endif
    }

    #if os(iOS)
    override func layoutSublayers(of layer: CALayer) {
        if layer == self.layer {
            self.gradientLayer.frame = self.bounds
        }
    }
    #endif

    #if os(macOS)
    override var isFlipped: Bool {
        true
    }
    #endif

    private var gradientChannelMask: HSL.ChannelMask {
        #if os(iOS)
        if self.traitCollection.userInterfaceStyle == .dark {
            [.lightness, .saturation]
        } else {
            [.lightness]
        }
        #endif
        #if os(macOS)
        if self.effectiveAppearance.isDarkMode {
            [.lightness, .saturation]
        } else {
            [.lightness]
        }
        #endif
    }

    override func draw(_ rect: CGRect) {
        self.layer().cornerRadius = self.cornerRadius
        self.gradientLayer.cornerRadius = self.cornerRadius
        self.updateGradientColor(self.color.cgColor)
    }

    private func updateGradientColor(_ color: CGColor) {
        self.gradientLayer.colors = CAGradientLayer.colors(
            hslGradientStart: color,
            end: Colors.cardBackground.cgColor,
            channelMask: self.gradientChannelMask,
            curve: .cubic,
            stops: 10
        )
        self.gradientLayer.startPoint = CGPointMake(0, -10.0 / self.bounds.height)
        self.gradientLayer.endPoint = CGPointMake(0, self.gradientHeight / self.bounds.height)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
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
            BackgroundView()
        }

        func updateView(_ view: ViewType, context: Context) {

        }
    }
}

#Preview {
    VStack {
        BackgroundView.Preview()
            .border(.black.opacity(0.25))
    }
    .padding(10)
}
