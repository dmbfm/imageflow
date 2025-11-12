import Foundation

public enum ValueSemantics: String, Sendable, Hashable, Codable {
    case `default`
    case time
    case distance
    case angle
    case boolean
    case integer
    case count
    case offset
    case position2
    case position3
    case rectangle
    case opaqueColor
    case gradient
    case color
    case image
    case transform
    case scaleVector
}
