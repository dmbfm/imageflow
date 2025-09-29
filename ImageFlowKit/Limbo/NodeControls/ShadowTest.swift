//
//  ShadowTest.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 08/08/25.
//

#if canImport(AppKit)
import AppKit
import SwiftUI
import Design

class ShadowTest: NSView {

    lazy var inner: InnerView = {
        let view = InnerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidMoveToSuperview() {
        self.clipsToBounds = false
        self.wantsLayer = true

        self.shadow = NSShadow()
        self.layer?.shadowRadius = 4
        self.layer?.shadowOpacity = 1
        self.layer?.shadowOffset = .init(width: 0, height: -4)
        self.layer?.shadowColor = .blue
        /// .init(gray: 0, alpha: 0.25)
        self.layer?.borderWidth = 2
        self.layer?.borderColor = NSColor.systemBlue.cgColor
        self.layer?.cornerRadius = 6

        self.addSubview(self.inner)
        self.inner.constraintToFill(self, edgeInsets: .init(top: 0, left: 0, bottom: 0, right: 0))
    }

    override func draw(_ dirtyRect: NSRect) {
        self.layer?.shadowColor = .init(gray: 0, alpha: 0.45)
    }

    override var intrinsicContentSize: NSSize {
        .init(width: 30, height: 22)
    }

    class InnerView: NSView {
        var shapeLayer: CAShapeLayer!

        override var intrinsicContentSize: NSSize {
            .init(width: 30, height: 22)
        }

        override func viewDidMoveToSuperview() {
            self.wantsLayer = true
            self.layer?.backgroundColor = Colors.numberInputBackground.cgColor
            //        self.layer?.borderWidth = 2
            //        self.layer?.borderColor = NSColor.systemBlue.cgColor
            self.layer?.cornerRadius = 8
            //        self.layer?.shadowRadius = 20
            //        self.layer?.shadowOpacity = 0.2
            //        self.layer?.shadowOffset = .zero
            //        self.layer?.shadowColor = .blue
            //        self.clipsToBounds = false

            self.shapeLayer = CAShapeLayer()
            self.shapeLayer.path = .init(rect: self.bounds.insetBy(dx: 4, dy: 4), transform: nil)
            self.shapeLayer.strokeColor = .clear
            self.shapeLayer.fillColor = .clear

            self.shapeLayer.frame = self.bounds
            self.shapeLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            self.layer?.addSublayer(self.shapeLayer)
        }

        override func draw(_ dirtyRect: NSRect) {
            let outer = CGPath(rect: self.bounds, transform: nil)
            let inner = CGPath(rect: self.bounds.insetBy(dx: 2, dy: 2), transform: nil)
            let path = outer.subtracting(inner)
            self.shapeLayer.path = path
            //        self.shapeLayer.path = .init(rect: self.bounds.insetBy(dx: 10, dy: 10), transform: nil)
            self.shapeLayer.shadowPath = self.shapeLayer.path
            self.shapeLayer.shadowRadius = 4
            self.shapeLayer.shadowColor = .init(gray: 0, alpha: 0.45)
            self.shapeLayer.shadowOpacity = 1
            self.shapeLayer.shadowOffset = .init(width: 0, height: -4)
        }
    }

    struct Preview: NSViewRepresentable {
        func makeNSView(context: Context) -> some NSView {
            ShadowTest()
        }

        func updateNSView(_ nsView: NSViewType, context: Context) {
        }

        func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSViewType, context: Context) -> CGSize? {
            nsView.intrinsicContentSize
        }
    }
}

#Preview {
    VStack {
        ShadowTest.Preview()
    }
    .frame(width: 500, height: 500)
    .background(.white)

}

#endif
