//
//  PortView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 03/08/25.
//

import Helpers
import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

final class PortView: PlatformView {

    // MARK: - State

    var connected: Bool {
        didSet {
            if self.connected != oldValue {
                self.setNeedsDisplay()
            }
        }
    }

    var onEvent: ((Event) -> ())?

    enum Event {
        case drag(DragData)
    }

    struct DragData {
        public var phase: GesturePhase
        public var locationInWindow: CGPoint
    }

    // MARK: - Style

    private var style: Style

    struct Style: Sendable, Hashable, With {
        var size: CGFloat
        var connectedColor: PlatformColor
        var emptyColor: PlatformColor
        var strokeWidth: CGFloat

        static var `default`: Style {
            .init(
                size: 12,
                connectedColor: Colors.portConnected.platformColor,
                emptyColor: Colors.portEmpty.platformColor,
                strokeWidth: 1.5
            )
        }
    }

    // MARK: - Initializers

    init(connected: Bool = false, style: Style = .default) {
        self.connected = connected
        self.style = style

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
        let w = style.strokeWidth
        let rect: CGRect = .init(x: 0, y: 0, width: self.style.size, height: self.style.size).insetBy(
            dx: w * 0.5,
            dy: w * 0.5
        )
        let path = UIBezierPath(ovalIn: rect)
        UIColor.clear.setFill()
        UIRectFill(rect)

        if self.connected {
            Colors.portConnected.platformColor.setFill()
            Colors.portConnected.platformColor.setStroke()
            path.fill()
            path.lineWidth = w
            path.stroke()
        } else {
            Colors.portEmpty.platformColor.setFill()
            Colors.portConnected.platformColor.setStroke()
            path.fill()
            path.lineWidth = w
            path.stroke()
        }
    }

    #endif

    // MARK: - macOS
    #if os(macOS)
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
        let rect = CGRect(x: 0, y: 0, width: self.style.size, height: self.style.size).insetBy(
            dx: style.strokeWidth * 0.5,
            dy: style.strokeWidth * 0.5
        )
        let path = NSBezierPath(ovalIn: rect)

        if self.connected {
            Colors.portConnected.platformColor.setFill()
            Colors.portConnected.platformColor.setStroke()
            path.fill()
            path.stroke()
        } else {
            Colors.portEmpty.platformColor.setFill()
            Colors.portConnected.platformColor.setStroke()
            path.fill()
            path.lineWidth = style.strokeWidth
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
        var style: PortView.Style? = nil
        func makeView(context: Context) -> PortView {
            let view = PortView(connected: self.connected, style: self.style ?? .default)
            view.translatesAutoresizingMaskIntoConstraints = false
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
    VStack {
        HStack {
            PortView.Preview(style: .default.with(\.size, 8).with(\.strokeWidth, 1))
                .border(.gray.opacity(0.25))
            PortView.Preview(connected: true, style: .default.with(\.size, 8).with(\.strokeWidth, 1))
                .border(.gray.opacity(0.25))
        }

        HStack {
            PortView.Preview()
                .border(.gray.opacity(0.25))
            PortView.Preview(connected: true)
                .border(.gray.opacity(0.25))
        }
        HStack {
            PortView.Preview(style: .default.with(\.size, 12).with(\.strokeWidth, 1))
                .border(.gray.opacity(0.25))
            PortView.Preview(connected: true, style: .default.with(\.size, 12).with(\.strokeWidth, 1))
                .border(.gray.opacity(0.25))
        }
        HStack {
            PortView.Preview(style: .default.with(\.size, 12))
                .border(.gray.opacity(0.25))
            PortView.Preview(connected: true, style: .default.with(\.size, 12))
                .border(.gray.opacity(0.25))
        }
        HStack {
            PortView.Preview(style: .default.with(\.size, 16).with(\.strokeWidth, 3))
                .border(.gray.opacity(0.25))
            PortView.Preview(connected: true, style: .default.with(\.size, 16).with(\.strokeWidth, 3))
                .border(.gray.opacity(0.25))
        }
    }
    .padding()
}
