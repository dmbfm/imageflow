//
//  PortView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 03/08/25.
//

import Design
import EventEmitter
import PlatformUtils
import SwiftUI

#if canImport(AppKit)
import AppKit
typealias PortView = PortViewAppKit
#endif

#if canImport(UIKit)
import UIKit
typealias PortView = PortViewUIKit
#endif

// MARK: - iOS

#if os(iOS)
public final class PortViewUIKit: UIView {
    // MARK: - Public Properties

    public var connected: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var size: CGFloat = 4.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var emitter: EventEmitter<Event> = .init()

    init(connected: Bool = false, size: CGFloat = 4.0) {
        self.connected = connected
        self.size = size

        super.init(frame: .zero)

        self.backgroundColor = .clear
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override func draw(_ rect: CGRect) {
        let center = self.bounds.center
        let hs = self.size * 0.5
        let rect = CGRect(x: center.x - hs, y: center.y - hs, width: self.size, height: self.size)
        if self.connected {
            Colors.portConnected.platformColor.setFill()
        } else {
            Colors.portEmpty.platformColor.setFill()
        }
        UIBezierPath(ovalIn: rect).fill()
    }

}
#endif

// MARK: - macOS

#if os(macOS)
public final class PortViewAppKit: NSView {
    // MARK: - Public Properties

    public var connected: Bool = false {
        didSet {
            self.needsDisplay = true
        }
    }

    public var size: CGFloat = 4.0 {
        didSet {
            self.needsDisplay = true
        }
    }

    public var emitter: EventEmitter<Event> = .init()

    // MARK: - Initialization

    public override init(frame: NSRect) {
        super.init(frame: frame)

        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(self.panGestureHandler(_:)))
        self.addGestureRecognizer(panGesture)

    }

    // public override func updateTrackingAreas() {
    //     super.updateTrackingAreas()

    //     for trackingArea in self.trackingAreas {
    //         self.removeTrackingArea(trackingArea)
    //     }

    //     self.addTrackingArea(.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil))
    // }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Drawing

    public override var isFlipped: Bool {
        true
    }

    public override func draw(_ dirtyRect: NSRect) {
        let color =
            if self.connected {
                Colors.portConnected.platformColor
            } else {
                Colors.portEmpty.platformColor
            }

        let center = self.bounds.center
        let hs = self.size * 0.5
        let rect = NSRect(
            origin: CGPoint(x: center.x - hs, y: center.y - hs),
            size: CGSize(width: self.size, height: self.size)
        )

        // let diameter = min(self.frame.width, self.frame.height)
        // let rect = NSRect(x: 0, y: 0, width: diameter, height: diameter)
        color.setFill()
        NSBezierPath(ovalIn: rect).fill()
    }

    // MARK: - User Interaction
    var gestureCancelled: Bool = false

    @objc
    func panGestureHandler(_ gesture: NSPanGestureRecognizer) {
        if gesture.state == .began {
            self.gestureCancelled = false
        }

        if self.gestureCancelled {
            gesture.reset()
            return
        }

        let phase = GesturePhase(gestureRecognizerState: gesture.state)  //GesturePhase(nsGestureRecognizerState: gesture.state)
        let locationInWindow = gesture.location(in: nil)

        let data = DragData(phase: phase, locationInWindow: locationInWindow)

        self.emitter.emit(.drag(data))
    }

    public func cancelDrag() {
        self.gestureCancelled = true
    }

    public override func mouseEntered(with event: NSEvent) {
        NSCursor.openHand.push()
    }

    public override func mouseExited(with event: NSEvent) {
        NSCursor.pop()
    }
}
#endif

extension PortView {
    public struct DragData {
        public var phase: GesturePhase
        public var locationInWindow: CGPoint
    }
    public enum Event {
        case drag(DragData)
    }
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
    }
}

#Preview {
    HStack {
        PortView.Preview()
            .frame(width: 16, height: 16)
            .border(.black)
        PortView.Preview(connected: true)
            .frame(width: 16, height: 16)
    }
    .padding()
    .background(Color.white)
}
