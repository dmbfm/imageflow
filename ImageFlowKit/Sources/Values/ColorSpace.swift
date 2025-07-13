import CoreGraphics
import Foundation

public enum ColorSpace: Sendable, Codable, Hashable {
    case sRGB
    case named(String)

    public func cgColorSpace() -> CGColorSpace {
        switch self {
        case .sRGB:
            return CGColorSpace(name: CGColorSpace.sRGB)!
        case .named(let name):
            return CGColorSpace(name: name as CFString)!
        }
    }
}
