import Design
import Helpers
import SwiftUI
import XKit

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

final class BackgroundView: XViewEx {

    public var style: TextInputBackgroundStyle {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var progress: Double? = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }

    lazy var fillLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = CGPath(rect: .init(origin: .zero, size: .init(width: 100, height: 30)), transform: nil)
        return layer
    }()

    init(style: TextInputBackgroundStyle = .default) {
        self.style = style

        super.init(frame: .zero)

        #if os(macOS)
        self.wantsLayer = true
        guard let layer = self.layer else { return }
        #else
        let layer = self.layer
        #endif

        layer.masksToBounds = true
        layer.addSublayer(self.fillLayer)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func draw(_ dirtyRect: CGRect) {

        #if os(macOS)
        guard let layer = self.layer else { return }
        #else
        let layer = self.layer
        #endif

        layer.cornerRadius = self.style.radius
        layer.backgroundColor = self.style.backgroundColor?.cgColor
        layer.borderColor = self.style.borderColor?.cgColor
        layer.borderWidth = self.style.borderWidth

        if let progress = self.progress?.clamped(to: 0...1) {
            self.fillLayer.isHidden = false
            self.fillLayer.path = .init(
                rect: .init(x: 0, y: 0, width: self.bounds.width * progress, height: self.bounds.height),
                transform: nil
            )
            self.fillLayer.fillColor = self.style.progressColor?.cgColor
        } else {
            self.fillLayer.isHidden = true
        }
    }
}

public struct TextInputBackgroundStyle: Sendable, Equatable, With {
    public var backgroundColor: XColor?
    public var borderColor: XColor?
    public var progressColor: XColor?
    public var borderWidth: CGFloat
    public var radius: CGFloat

    internal init(
        backgroundColor: XColor?,
        progressColor: XColor?,
        borderColor: XColor?,
        borderWidth: CGFloat,
        radius: CGFloat
    ) {
        self.backgroundColor = backgroundColor
        self.progressColor = progressColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.radius = radius
    }

    static let `default`: Self = .init(
        backgroundColor: .system.secondaryFill,
        progressColor: .system.secondaryFill,
        borderColor: .system.fill,
        borderWidth: 1,
        radius: 6
    )
}

private struct Preview: XViewRepresentable {

    var style: TextInputBackgroundStyle = .default

    func makeView(context: Context) -> BackgroundView {
        let view = BackgroundView(style: self.style)
        view.progress = 0.25
        return view
    }

    func updateView(_ view: BackgroundView, context: Context) {

    }
}

#Preview {
    VStack {
        Preview()
            .frame(width: 200, height: 30)
    }
    .padding()
}
