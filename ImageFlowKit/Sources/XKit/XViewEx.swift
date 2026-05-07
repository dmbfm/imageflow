import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

open class XViewEx: XView {

    // MARK: - macOS

    #if os(macOS)
    public var backgroundColor: NSColor? = nil {
        didSet {
            self.layer?.backgroundColor = backgroundColor?.cgColor
        }
    }

    open override func updateLayer() {
        super.updateLayer()
        self.updateLayerBackgroundColor()
        self.updateLayerBorder()
        self.upadateLayerShadow()
    }

    open override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if !self.wantsUpdateLayer {
            self.updateLayerBackgroundColor()
            self.updateLayerBorder()
            self.upadateLayerShadow()
        }
    }

    private func updateLayerBackgroundColor() {
        if let color = self.backgroundColor {
            self.withLayer { layer in
                layer.backgroundColor = color.cgColor
            }
        }
    }

    public var contentScale: CGFloat {
        self.window?.backingScaleFactor ?? 2.0
    }

    open override var isFlipped: Bool { true }
    #endif

    // MARK: - iOS

    #if os(iOS)
    open override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        self.upadateLayerShadow()
        self.updateLayerBorder()
    }
    #endif

    // MARK: - Common

    public var border: Border? {
        didSet {
            self.updateLayerBorder()
        }
    }

    private var _shadow: Shadow? {
        didSet {

        }
    }

    public func shadow(_ shadow: Shadow?) {
    }

    func upadateLayerShadow() {
        if let shadow = self._shadow {
            #if os(macOS)
            if self.shadow == nil {
                self.shadow = .init()
            }
            #endif

            self.withLayer { layer in
                layer.shadowColor = shadow.color.cgColor
                layer.shadowRadius = shadow.radius
                layer.shadowOffset = shadow.offset
                layer.shadowOpacity = Float(shadow.opacity)
            }

        } else {
            #if os(macOS)
            if self.shadow != nil {
                self.shadow = nil
            }
            #endif

            self.withLayer { layer in
                layer.shadowColor = nil
            }
        }
    }

    func updateLayerBorder() {
        self.withLayer { layer in
            if let border = self.border {
                layer.borderColor = border.color.cgColor
                layer.borderWidth = border.width
            } else {
                layer.borderColor = nil
                layer.borderWidth = 0
            }
        }
    }
}

extension XViewEx {
    public struct Border: Sendable, Equatable, Hashable {
        public var color: XColor
        public var width: CGFloat

        public init(color: XColor, width: CGFloat) {
            self.color = color
            self.width = width
        }
    }

    public struct Shadow: Sendable, Equatable, Hashable {
        public var color: XColor
        public var opacity: CGFloat
        public var offset: CGSize
        public var radius: CGFloat

        public init(color: XColor, opacity: CGFloat, offset: CGSize, radius: CGFloat) {
            self.color = color
            self.opacity = opacity
            self.offset = offset
            self.radius = radius
        }
    }
}

extension XViewEx {
    fileprivate struct Preview: XViewRepresentable {
        func makeView(context: Context) -> XViewEx {
            let view = XViewEx(frame: .zero)
            view.backgroundColor = .system.fill
            view.border = .init(color: XColor(light: .red, dark: .blue), width: 4)
            return view
        }

        func updateView(_ view: XViewEx, context: Context) {

        }
    }
}

#Preview {
    VStack {
        XViewEx.Preview()
    }
}
