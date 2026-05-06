import Foundation
import Helpers
import SwiftUI
import XKit

#if os(iOS)
import UIKit
// typealias AngleDialView = AngleDialUIView
#endif

#if os(macOS)
import AppKit
// typealias AngleDialView = AngleDialNSView
#endif

// MARK: - AngleDialView

final class AngleDialView: XViewEx {

    // MARK: - Exposed Properties

    var angle: Double {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var range: ClosedRange<Double>? = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var style: Style {
        didSet {
            self.setNeedsDisplay()
        }
    }

    // MARK: - Private Properties

    private lazy var largeCircleLayer: CAShapeLayer = {
        .init()
    }()

    private lazy var smallCircleLayer: CAShapeLayer = {
        .init()
    }()

    private lazy var rangeCircleLayer: CAShapeLayer = {
        .init()
    }()

    private var drawData: DrawData

    #if os(macOS)
    private typealias PlatformPath = NSBezierPath
    #else
    private typealias PlatformPath = UIBezierPath
    #endif

    // MARK: - Initialization

    init(angle: Double, range: ClosedRange<Double>? = nil, style: Style = .default) {
        self.angle = angle
        self.range = range
        self.style = style
        self.drawData = .init(.init(origin: .zero, size: .init(width: 50, height: 50)), self.angle, 0.25)

        super.init(frame: .zero)

        #if os(macOS)
        self.wantsLayer = true

        self.layer?.addSublayer(self.largeCircleLayer)
        self.layer?.addSublayer(self.rangeCircleLayer)
        self.layer?.addSublayer(self.smallCircleLayer)
        #else
        self.layer.addSublayer(self.largeCircleLayer)
        self.layer.addSublayer(self.rangeCircleLayer)
        self.layer.addSublayer(self.smallCircleLayer)
        #endif
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        self.drawData = .init(self.bounds, self.angle, 0.25)
        self.drawLargeCircle()
        self.drawSmallCircle()
        self.drawRangeCircle()
    }

    func drawLargeCircle() {
        let path = PlatformPath(ovalIn: self.drawData.largeCircleRect)

        if self.range == nil {
            self.largeCircleLayer.fillColor = self.style.fillColor.cgColor
            self.largeCircleLayer.strokeColor = self.style.color.cgColor
        } else {
            self.largeCircleLayer.fillColor = .init(gray: 0, alpha: 0)
            self.largeCircleLayer.strokeColor = self.style.color.cgColor
            self.largeCircleLayer.lineDashPattern = [2.0, 2.0]
        }

        self.largeCircleLayer.path = path.cgPath
    }

    func drawSmallCircle() {
        let path = PlatformPath(ovalIn: self.drawData.smallCircleRect)

        self.smallCircleLayer.strokeColor = nil
        self.smallCircleLayer.fillColor = self.style.color.cgColor
        self.smallCircleLayer.path = path.cgPath
    }

    func drawRangeCircle() {
        guard let range = self.range else {
            self.rangeCircleLayer.path = nil
            return
        }

        let path = CGMutablePath()

        let center = self.drawData.largeCircleRect.center
        let radius = self.drawData.largeCircleRect.width * 0.5
        path.move(to: center)
        path.addLine(
            to: .init(
                x: center.x + radius * cos(range.lowerBound),
                y: center.y + radius * sin(range.lowerBound)
            )
        )
        path.addArc(
            center: center,
            radius: radius,
            startAngle: range.lowerBound,
            endAngle: range.upperBound,
            clockwise: false
        )
        path.addLine(to: center)

        self.rangeCircleLayer.path = path
        self.rangeCircleLayer.fillColor = style.fillColor.cgColor
        self.rangeCircleLayer.strokeColor = style.color.cgColor
    }
}

// MARK: - Style

extension AngleDialView {
    struct Style {
        var fillColor: DynamicColor = .init(light: .init(white: 0.85, alpha: 1.0), dark: .init(white: 0.15, alpha: 1.0))
        var color: DynamicColor = .init(light: .init(white: 0.6, alpha: 1.0), dark: .init(white: 0.4, alpha: 1.0))

        static var `default`: Self {
            .init()
        }
    }
}

// MARK: - DrawData

extension AngleDialView {
    struct DrawData {
        var largeCircleRect: CGRect
        var smallCircleRect: CGRect

        init(_ bounds: CGRect, _ angle: Double, _ smallRadiusRatio: Double) {
            let boundsMinSide = min(bounds.width - 2, bounds.height - 2)
            let alpha = smallRadiusRatio

            let largeRadius = boundsMinSide / (2 * (1.0 + alpha))
            let smallRadius = largeRadius * alpha
            let bounds = bounds.insetBy(dx: smallRadius + 2, dy: smallRadius + 2)

            let square = CGRect(origin: bounds.origin, size: .init(width: 2 * largeRadius, height: 2 * largeRadius))
            let center = square.center
            let x = center.x + largeRadius * cos(angle) - smallRadius
            let y = center.y - largeRadius * sin(angle) - smallRadius
            let smallCircleRect = CGRect(x: x, y: y, width: 2 * smallRadius, height: 2 * smallRadius)

            self.largeCircleRect = square
            self.smallCircleRect = smallCircleRect
        }
    }
}

// MARK: - Previews

extension AngleDialView {
    struct Preview: XViewRepresentable {
        var angle: Double
        var range: ClosedRange<Double>? = nil
        func makeView(context: Context) -> AngleDialView {
            let view = AngleDialView(angle: self.angle, range: self.range)
            return view
        }

        func updateView(_ view: AngleDialView, context: Context) {

        }
    }
}

#Preview {
    VStack {
        AngleDialView.Preview(angle: 45.0.radians)
            .frame(width: 25, height: 25)
        AngleDialView.Preview(angle: 45.0.radians, range: (-.pi * 0.25)...(.pi * 0.25))
            .frame(width: 25, height: 25)
    }
    .frame(minWidth: 300, minHeight: 300)
}
