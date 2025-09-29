//
//  PortView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 03/08/25.
//

import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

public final class PortView: PlatformView {

    // MARK: - State

    public var connected: Bool {
        didSet {
            if self.connected != oldValue {
                self.setNeedsDisplay()
            }
        }
    }

    public var onEvent: ((Event) -> ())?

    public enum Event {
        case drag(DragData)
    }

    public struct DragData {
        public var phase: GesturePhase
        public var locationInWindow: CGPoint
    }

    // MARK: - Style

    struct Style {
        var size: CGFloat

        static var iOS: Self {
            .init(size: Design.default.portSize)
        }

        static var macOS: Self {
            .init(size: Design.default.portSize)
        }
    }

    // MARK: - Initializers

    init(connected: Bool = false) {
        self.connected = connected

        super.init(frame: .zero)

        self.platformInit()
    }

    public required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Common Methods

    public override var intrinsicContentSize: CGSize {
        .init(width: self.style.size, height: self.style.size)
    }

    // MARK: - iOS
    #if os(iOS)
    var style: Style = .iOS

    func platformInit() {
        self.backgroundColor = .clear
        self.clipsToBounds = false

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler(_:)))
        self.addGestureRecognizer(panGesture)
    }

    @objc
    func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        self.onEvent?(
            .drag(
                .init(phase: .init(gestureRecognizerState: gesture.state), locationInWindow: gesture.location(in: nil))
            )
        )
    }

    public override func draw(_ rect: CGRect) {
        let w = Design.default.portStrokeWidth
        let rect: CGRect = .init(x: 0, y: 0, width: self.style.size, height: self.style.size).insetBy(
            dx: w * 0.5,
            dy: w * 0.5
        )
        let path = UIBezierPath(ovalIn: rect)
        UIColor.clear.setFill()
        UIRectFill(rect)

        if self.connected {
            Colors.portConnected.platformColor.setFill()
            path.fill()
        } else {
            Colors.portEmpty.platformColor.setFill()
            Colors.portConnected.platformColor.setStroke()
            path.fill()
            path.lineWidth = w
            path.stroke()
        }

        //        UIBezierPath(ovalIn: .init(x: 0, y: 0, width: self.style.size, height: self.style.size)).fill()
    }

    #endif

    // MARK: - macOS
    #if os(macOS)
    var style: Style = .macOS

    func platformInit() {
        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler(_:)))
        self.addGestureRecognizer(panGesture)
    }

    @objc
    func panGestureHandler(_ gesture: NSPanGestureRecognizer) {
        self.onEvent?(
            .drag(
                .init(phase: .init(gestureRecognizerState: gesture.state), locationInWindow: gesture.location(in: nil))
            )
        )
    }

    public override func draw(_ dirtyRect: NSRect) {
        let rect = CGRect(x: 0, y: 0, width: self.style.size, height: self.style.size).insetBy(dx: 0.5, dy: 0.5)
        let path = NSBezierPath(ovalIn: rect)

        if self.connected {
            Colors.portConnected.platformColor.setFill()
            path.fill()
        } else {
            Colors.portEmpty.platformColor.setFill()
            Colors.portConnected.platformColor.setStroke()
            path.fill()
            path.stroke()
        }
    }

    public override var isFlipped: Bool {
        true
    }
    #endif

}

// MARK: - Previews

extension PortView {
    struct Preview: PlatformViewRepresentable {
        var connected: Bool = false
        func makeView(context: Context) -> PortView {
            let view = PortView()
            view.connected = self.connected
            view.translatesAutoresizingMaskIntoConstraints = false
            // view.frame = .init(x: 0, y: 0, width: 16, height: 16)
            return view
        }

        func updateView(_ nsView: PortView, context: Context) {
        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: PortView, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    HStack {
        PortView.Preview()
        //            .border(.gray.opacity(0.25))
        PortView.Preview(connected: true)
    }
    .padding()
}
