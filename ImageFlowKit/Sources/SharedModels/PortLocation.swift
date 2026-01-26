import Foundation
import Values

public struct PortLocation: Hashable, Sendable, Codable {
    public var node: UUID
    public var slot: PortSlot

    public init(node: UUID, port: PortSlot) {
        self.node = node
        self.slot = port
    }

    public func canConnectWith(_ other: Self) -> Bool {
        self.node != other.node && !self.slot.sameSideAs(other.slot)
    }

    public var direction: PortDirection {
        self.slot.direction
    }
}

public enum PortSlot: Hashable, Sendable, Codable {
    case input(Int)
    case output(Int)

    public func sameSideAs(_ other: PortSlot) -> Bool {
        switch (self, other) {
        case (.input, .input), (.output, .output):
            true
        default:
            false
        }
    }

    public var index: Int {
        switch self {
        case .input(let index):
            index
        case .output(let index):
            index
        }
    }

    public var isInput: Bool {
        if case .input = self {
            true
        } else {
            false
        }
    }

    public var isOutput: Bool {
        if case .output = self {
            true
        } else {
            false
        }
    }

    public var direction: PortDirection {
        switch self {
        case .input(_): .input
        case .output(_): .output
        }
    }
}

public struct InputPortLocation: Hashable, Sendable, Codable {
    public var node: UUID
    public var index: Int

    public init(node: UUID, index: Int) {
        self.node = node
        self.index = index
    }
}

public struct OutputPortLocation: Hashable, Sendable, Codable {
    public var node: UUID
    public var index: Int

    public init(node: UUID, index: Int) {
        self.node = node
        self.index = index
    }
}

public struct TypedPortLocation {
    public init(type: ValueType, port: PortLocation) {
        self.type = type
        self.port = port
    }

    public var type: ValueType
    public var port: PortLocation
    public var direction: PortDirection {
        self.port.direction
    }
}

public enum PortDirection: Equatable {
    case input
    case output
}
