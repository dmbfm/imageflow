import ColorUtils

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

extension PlatformView {
    public func constraintToFill(_ view: PlatformView, edgeInsets: PlatformEdgeInsets = .init()) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: edgeInsets.top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -edgeInsets.bottom),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeInsets.left),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeInsets.right),
        ])
    }

    public func border(_ color: PlatformColor, width: CGFloat = 1) {
        #if os(macOS)
        self.wantsLayer = true
        self.layer?.borderColor = color.cgColor
        self.layer?.borderWidth = width
        #endif

        #if os(iOS)
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
        #endif
    }
}
