import Backend
import Foundation
import Helpers

public struct Edge: Hashable, Sendable, Identifiable, Codable {
    public var id: Self { self }
    let a: PortLocation
    let b: PortLocation

    public init(uncheckedA a: PortLocation, b: PortLocation) {
        self.a = a
        self.b = b
    }

    public func isValid() -> Bool {
        self.a.canConnectWith(self.b)
    }

    public init?(_ a: PortLocation, _ b: PortLocation) {
        self.init(ports: (a, b))
    }

    public init?(ports: (PortLocation, PortLocation)) {
        let a = ports.0
        let b = ports.1

        if !a.canConnectWith(b) {
            return nil
        }

        self.a = a
        self.b = b
    }

    public var from: PortLocation {
        self.a.slot.isOutput ? self.a : self.b
    }

    public var to: PortLocation {
        self.a.slot.isInput ? self.a : self.b
    }

    public var backendEdge: Backend.Edge {
        .init(
            from: .init(node: self.from.node, slot: self.from.slot.index),
            end: .init(node: self.to.node, slot: self.to.slot.index)
        )
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

    //    var color: PlatformColor {
    //        switch self.state {
    //        case .default:
    //            Colors.portConnected.platformColor
    //        case .canConnect:
    //            Colors.edgeWithSuccess.platformColor
    //        case .cantConnect:
    //            Colors.edgeWithError.platformColor
    //        }
    //    }

}
