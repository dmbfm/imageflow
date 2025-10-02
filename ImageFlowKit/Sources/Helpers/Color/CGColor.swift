//
//  CGColor.swift
//  DFKitCoreGraphics
//
//  Created by Daniel Fortes on 23/09/24.
//

import CoreGraphics

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
public extension CGColor {
    static let blue: CGColor = UIColor.systemBlue.cgColor
    static let red: CGColor = UIColor.systemRed.cgColor
    static let pink: CGColor = UIColor.systemPink.cgColor
}
#endif

#if canImport(AppKit)
public extension CGColor {
    static let blue: CGColor = NSColor.systemBlue.cgColor
    static let red: CGColor = NSColor.systemRed.cgColor
    static let pink: CGColor = NSColor.systemPink.cgColor
    static let teal: CGColor = NSColor.systemTeal.cgColor
}
#endif

public extension CGColor {
    func transformHSB(
        transform: (inout CGFloat, inout CGFloat, inout CGFloat) -> Void
    ) -> CGColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        #if canImport(UIKit)
        UIColor(cgColor: self).getHue(
            &hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha
        )
        transform(&hue, &saturation, &brightness)
        return UIColor(
            hue: hue,
            saturation: saturation,
            brightness: brightness,
            alpha: alpha
        ).cgColor
        #elseif canImport(AppKit)
        NSColor(cgColor: self)!.getHue(
            &hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha
        )
        transform(&hue, &saturation, &brightness)
        return NSColor(
            hue: hue,
            saturation: saturation,
            brightness: brightness,
            alpha: alpha
        ).cgColor
        #endif
    }

    func desaturated(by percentage: Double) -> CGColor {
        self.transformHSB { _, s, _ in
            s *= CGFloat(1.0 - max(min(percentage, 1.0), 0.0))
        }
    }

    func dimmed(by percentage: Double) -> CGColor {
        self.transformHSB { _, _, b in
            b *= CGFloat(1.0 - max(min(percentage, 1.0), 0.0))
        }
    }

    static func lerp(_ a: CGColor, _ b: CGColor, _ t: CGFloat) -> CGColor {
        let aComponents = a.components!
        let bComponents = b.components!
        let components = zip(aComponents, bComponents).map { a, b in
            a + (b - a) * t
        }
        return CGColor(colorSpace: a.colorSpace!, components: components)!
    }
}
