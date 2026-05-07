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
    public var contentScale: CGFloat {
        self.window?.backingScaleFactor ?? 2.0
    }

    open override var isFlipped: Bool { true }
    #endif

    public func updateShadow(_ shadow: Shadow?) {
        if let shadow {
            #if os(macOS)
            if self.shadow == nil {
                self.shadow = .init()
            }
            #endif

            self.withLayer({ layer in
                layer.shadowColor = shadow.color.cgColor
                layer.shadowOffset = shadow.offset
                layer.shadowRadius = shadow.radius
                layer.shadowOpacity = Float(shadow.opacity)
            })
        } else {
            self.shadow = nil
            self.withLayer { layer in
                layer.shadowColor = nil
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
            // view.backgroundColor = .system.fill
            // view.border = .init(color: XColor(light: .red, dark: .blue), width: 4)
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
