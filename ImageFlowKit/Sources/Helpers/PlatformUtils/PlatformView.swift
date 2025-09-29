#if canImport(AppKit)
import AppKit
public typealias PlatformView = NSView
public typealias PlatformEdgeInsets = NSEdgeInsets
#endif

#if canImport(UIKit)
import UIKit
public typealias PlatformView = UIView
public typealias PlatformEdgeInsets = UIEdgeInsets
#endif

extension PlatformEdgeInsets {
    public var size: CGSize {
        .init(width: self.left + self.right, height: self.top + self.bottom)
    }
}

extension PlatformView {
    public func constraintToFill(_ view: PlatformView, edgeInsets: PlatformEdgeInsets = .init()) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: edgeInsets.top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -edgeInsets.bottom),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeInsets.left),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeInsets.right),
        ])
    }

    public func border(_ border: Border?) {
        #if os(macOS)
        guard let border else {
            self.layer?.borderWidth = 0
            return
        }
        self.wantsLayer = true
        self.layer?.borderColor = border.color.cgColor
        self.layer?.borderWidth = border.width
        #endif

        #if os(iOS)

        guard let border else {
            self.layer.borderWidth = 0
            return
        }

        self.layer.borderColor = border.color.cgColor
        self.layer.borderWidth = border.width
        #endif
    }

    public func shadow(_ shadow: Shadow?) {
        #if os(macOS)

        guard let shadow else {
            self.shadow = nil
            return
        }

        self.wantsLayer = true
        if let layer = self.layer {
            self.shadow = NSShadow()
            layer.shadowRadius = shadow.radius
            layer.shadowColor = .black
            layer.shadowOffset = shadow.offset
            layer.shadowOpacity = Float(shadow.opacity)
        }
        #endif
    }

    public struct Shadow {
        var radius: CGFloat
        var opacity: CGFloat
        var offset: CGSize = .zero

        public init(radius: CGFloat, opacity: CGFloat = 0.4, offset: CGSize = .zero) {
            self.radius = radius
            self.opacity = opacity
            self.offset = offset
        }
    }

    public struct Border {
        var color: PlatformColor
        var width: CGFloat = 1.0

        public init(color: PlatformColor, width: CGFloat) {
            self.color = color
            self.width = width
        }
    }
}
