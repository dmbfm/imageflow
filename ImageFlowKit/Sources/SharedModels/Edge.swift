import Backend
import Foundation
import Helpers

public struct Edge: Hashable, Sendable, Identifiable, Codable {
    public var id: Self { self }
    public let from: OutputPortLocation
    public let to: InputPortLocation

    public var fromPort: PortLocation {
        .init(node: self.from.node, port: .output(self.from.index))
    }

    public var toPort: PortLocation {
        .init(node: self.to.node, port: .input(self.to.index))
    }

    public var backendEdge: Backend.Edge {
        .init(
            from: .init(node: self.from.node, slot: self.from.index),
            end: .init(node: self.to.node, slot: self.to.index)
        )
    }

    init?(from: OutputPortLocation, to: InputPortLocation) {
        if from.node == to.node {
            return nil
        }

        self.from = from
        self.to = to
    }

    public static func fromPorts(_ a: PortLocation, _ b: PortLocation) -> Result<Edge, FromPortsError> {
        if a.node == b.node {
            return .failure(.sameNode)
        } else if a.slot.isInput && b.slot.isInput {
            return .failure(.bothInput)
        } else if a.slot.isOutput && b.slot.isOutput {
            return .failure(.bothOutput)
        }

        let (from, to): (OutputPortLocation, InputPortLocation) =
            if a.slot.isOutput {
                (.init(node: a.node, index: a.slot.index), .init(node: b.node, index: b.slot.index))
            } else {
                (.init(node: b.node, index: b.slot.index), .init(node: a.node, index: a.slot.index))
            }

        if let edge = Edge(from: from, to: to) {
            return .success(edge)
        }

        return .failure(.sameNode)
    }

    public enum FromPortsError: Error {
        case sameNode
        case bothInput
        case bothOutput
    }
}

public struct PartialEdge: Sendable, Equatable {
    public var port: PortLocation
    public var pointer: CGPoint
    public var state: State = .default

    public enum State: Sendable, Equatable {
        case `default`
        case cantConnect
        case canConnect
    }

    public init(port: PortLocation, pointer: CGPoint, state: PartialEdge.State = .default) {
        self.port = port
        self.pointer = pointer
        self.state = state
    }
}
