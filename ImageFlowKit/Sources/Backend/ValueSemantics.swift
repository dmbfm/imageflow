import Foundation

public enum ValueSemantics: Sendable, Hashable, Codable {
    case `default`
    case time
    case distance
    case angle
    case boolean
    case integer(IntegerSemantics)
    case nonZeroInteger
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

    static var integer: Self {
        .integer(.default)
    }

    public enum IntegerSemantics: Sendable, Hashable, Codable {
        case `default`
        case range(ClosedRange<Int>? = nil)
        case picker([PickerOption])

        public struct PickerOption: Sendable, Hashable, Codable {
            public var label: String?
            public var value: Int

            public init(label: String? = nil, value: Int) {
                self.label = label
                self.value = value
            }
        }
    }
}
