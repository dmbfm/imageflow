import ColorUtils
import Easing

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

extension CAGradientLayer {
    convenience init?(
        hslGradientStart start: CGColor,
        end: CGColor,
        channelMask: HSL.ChannelMask,
        curve: EasingCurve,
        stops: Int
    ) {
        guard
            let colors = Self.colors(
                hslGradientStart: start,
                end: end,
                channelMask: channelMask,
                curve: curve,
                stops: stops
            )
        else {
            return nil
        }
        self.init()
        self.colors = colors
    }

    public static func colors(
        hslGradientStart start: CGColor,
        end: CGColor,
        channelMask: HSL.ChannelMask,
        curve: EasingCurve,
        stops: Int
    ) -> [CGColor]? {

        guard let start = HSL(cgColor: start), let end = HSL(cgColor: end) else {
            return nil
        }

        return start.gradientColors(to: end, channelMask: channelMask, curve: curve, stops: stops).map { $0.cgColor }
    }
}
