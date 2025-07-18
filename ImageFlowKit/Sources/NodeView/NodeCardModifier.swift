import ColorUtils
import Design
import SwiftUI

#if canImport(AppKit)
    import AppKit
    import AppKitUtils
#endif

extension EnvironmentValues {
    @Entry var nodeCardShadow: NodeCardModifier.Shadow = .init()
}

/// Applies a gradient background and rounded corners characteristic of
/// imageflow node views.
public struct NodeCardModifier: ViewModifier {

    /// The tint color of the node card. This is the color of the top of the
    /// gradient wich dissolves into the background color.
    let tintColor: Color

    /// The background color the gradient will fade-out to (well, kinda. Not
    /// really. It will fade in lightness and/or saturation, *not in hue*).
    let backgroundColor: Color

    /// The shadow parameters to be used in the background view's `.shadow` modifier.
    // let shadow: Shadow
    @Environment(\.nodeCardShadow) var shadow

    public struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat

        public init(
            color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
            radius: CGFloat = 4.0,
            x: CGFloat = 0,
            y: CGFloat = 0
        ) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }
    }

    public init(
        tintColor: Color = .blue,
        backgroundColor: Color = Colors.cardBackground.color
        // shadow: Shadow = .init()
    ) {
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        // self.shadow = shadow
    }

    public func body(content: Content) -> some View {
        content.background {
            BackgroundView(tintColor: self.tintColor, backgroundColor: self.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: self.shadow.color, radius: self.shadow.radius, x: self.shadow.x, y: self.shadow.y)
        }
    }
}

extension View {
    /// Applies the `NodeCardModifier` modifier to this view. This gives a
    /// gradient background and rounded corners characteristic of imageflow node views.
    /// - Parameters:
    ///   - tintColor: The card's "tint" color, which the gradient will fade to the background color.
    ///   - shadow: The shadow parameters.
    ///
    /// - Returns:
    public func nodeCard(
        tintColor: Color = .blue,
        backgroundColor: Color = Colors.cardBackground.color
    ) -> some View {
        self.modifier(NodeCardModifier(tintColor: tintColor, backgroundColor: backgroundColor))
    }

    /// Override the default values for the card's shadow.
    /// - Parameters:
    ///   - color: The shadow's color.
    ///   - radius: The shadow's radius.
    ///   - x: The shadow's x offset.
    ///   - y: The shadow's y offset.
    ///
    /// - Returns:
    public func nodeCardShadow(
        color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> some View {
        self.environment(\.nodeCardShadow, .init(color: color, radius: radius, x: x, y: y))
    }
}

// MARK: - AppKit

#if os(macOS)
    struct BackgroundView: NSViewRepresentable {
        /// The start color of the gradient
        var tintColor: Color = .blue
        /// The end color of the gradient
        var backgroundColor: Color = Colors.cardBackground.color

        func makeNSView(context: Context) -> NativeBackgroundView {
            // resolve both colors from the SwiftUI environment
            let resolvedTint = tintColor.resolve(in: context.environment).cgColor
            let resolvedBG = backgroundColor.resolve(in: context.environment).cgColor

            let view = NativeBackgroundView(
                frame: .zero,
                gradientHeight: 60,
                tintColor: resolvedTint,
                backgroundColor: resolvedBG
            )

            // cache the initial tint
            return view
        }

        func updateNSView(_ nsView: NativeBackgroundView, context: Context) {
            nsView.tintColor = self.tintColor.resolve(in: context.environment).cgColor
            nsView.backgroundColor = self.backgroundColor.resolve(in: context.environment).cgColor
        }
    }

    class NativeBackgroundView: NSView {

        let gradientHeight: CGFloat

        var tintColor: CGColor {
            didSet {
                if self.tintColor != oldValue {
                    self.needsDisplay = true
                }
            }
        }

        var backgroundColor: CGColor {
            didSet {
                if self.backgroundColor != oldValue {
                    self.needsDisplay = true
                }
            }
        }

        private var gradientLayer: CAGradientLayer = CAGradientLayer()

        override var wantsUpdateLayer: Bool { true }

        override var isFlipped: Bool {
            true
        }

        private var gradientChannelMask: HSL.ChannelMask {
            if self.effectiveAppearance.isDarkMode {
                [.lightness, .saturation]
            } else {
                [.lightness]
            }
        }

        init(
            frame frameRect: NSRect,
            gradientHeight: CGFloat,
            tintColor: CGColor,
            backgroundColor: CGColor
        ) {
            self.gradientHeight = gradientHeight
            self.tintColor = tintColor
            self.backgroundColor = backgroundColor
            super.init(frame: frameRect)

            self.gradientLayer.frame = self.bounds
            self.gradientLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]

            self.wantsLayer = true
            self.layer?.insertSublayer(self.gradientLayer, at: 0)
        }

        override func updateLayer() {
            self.gradientLayer.startPoint = CGPointMake(0, -10.0 / self.bounds.height)
            self.gradientLayer.endPoint = CGPointMake(0, self.gradientHeight / self.bounds.height)
            self.gradientLayer.colors = CAGradientLayer.colors(
                hslGradientStart: self.tintColor,
                end: self.backgroundColor,
                channelMask: self.gradientChannelMask,
                curve: .cubic,
                stops: 10
            )
        }

        required init?(coder: NSCoder) {
            nil
        }
    }
#endif

// MARK: - UIKit

#if os(iOS)
    class NativeBackgroundView: UIView {

        // MARK: – Public API

        /// Height of the gradient in points.
        let gradientHeight: CGFloat

        /// Tint‐color for the gradient start.
        /// When set, we mark the view dirty so layoutSubviews will re‐run the gradient update.
        var gradientTintColor: CGColor {
            didSet {
                if self.gradientTintColor != oldValue {
                    self.setNeedsLayout()
                    self.setNeedsDisplay()
                }
            }
        }

        var gradientBackgroundColor: CGColor {
            didSet {
                if self.gradientBackgroundColor != oldValue {
                    self.setNeedsLayout()
                    self.setNeedsDisplay()
                }
            }
        }

        // MARK: – Private

        private let gradientLayer = CAGradientLayer()

        private var gradientChannelMask: HSL.ChannelMask {
            // mimic your macOS isDarkMode check
            if traitCollection.userInterfaceStyle == .dark {
                return [.lightness, .saturation]
            } else {
                return [.lightness]
            }
        }

        // MARK: – Initializers

        /// Designated initializer, same API as your NSView version.
        init(
            frame: CGRect,
            gradientHeight: CGFloat,
            tintColor: CGColor,
            backgroundColor: CGColor
        ) {
            self.gradientHeight = gradientHeight
            self.gradientTintColor = tintColor
            self.gradientBackgroundColor = backgroundColor
            super.init(frame: frame)

            // set up our layer
            layer.addSublayer(gradientLayer)
            gradientLayer.needsDisplayOnBoundsChange = true

            // if you still want a fill behind the gradient:
            // layer.backgroundColor = endColor
        }

        required init?(coder: NSCoder) {
            // we don’t support IB/storyboards
            return nil
        }

        // MARK: – Layout & Appearance

        override func layoutSubviews() {
            super.layoutSubviews()

            // match the layer to our bounds
            gradientLayer.frame = bounds

            // recalc gradient
            updateGradient()
        }

        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)

            // when user switches light/dark, re‐layout the gradient
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                setNeedsLayout()
            }
        }

        // MARK: – Gradient Logic

        private func updateGradient() {
            // same geometry as you had in updateLayer()
            gradientLayer.startPoint = CGPoint(x: 0, y: -10.0 / bounds.height)
            gradientLayer.endPoint = CGPoint(x: 0, y: gradientHeight / bounds.height)

            gradientLayer.colors = CAGradientLayer.colors(
                hslGradientStart: self.gradientTintColor,
                end: self.gradientBackgroundColor,
                channelMask: gradientChannelMask,
                curve: .cubic,
                stops: 10
            )
        }
    }

    struct BackgroundView: UIViewRepresentable {
        /// The start color of the gradient
        var tintColor: Color = .blue
        /// The end color of the gradient
        var backgroundColor: Color = Colors.cardBackground.color

        func makeUIView(context: Context) -> NativeBackgroundView {
            let resolvedTint = tintColor.resolve(in: context.environment).cgColor
            let resolvedBG = backgroundColor.resolve(in: context.environment).cgColor

            let view = NativeBackgroundView(
                frame: .zero,
                gradientHeight: 60,
                tintColor: resolvedTint,
                backgroundColor: resolvedBG
            )
            return view
        }

        func updateUIView(_ uiView: NativeBackgroundView, context: Context) {
            uiView.gradientTintColor = self.tintColor.resolve(in: context.environment).cgColor
            uiView.gradientBackgroundColor = self.backgroundColor.resolve(in: context.environment).cgColor
        }
    }

#endif

// MARK: - Previews

#Preview {
    VStack {
        Text("Hello!")
            .padding(50)
    }
    .nodeCard(tintColor: .pink)
    .nodeCardShadow(radius: 10)
    .padding(100)
}
