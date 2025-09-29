import Foundation

public struct BackendEdge: Sendable, Equatable {

    public var from: Port
    public var to: Port

    public struct Port: Sendable, Equatable {
        public var node: UUID
        public var index: Int

        public init(node: UUID, slot: Int) {
            self.node = node
            self.index = slot
        }
    }

    public init(from: BackendEdge.Port, end: BackendEdge.Port) {
        self.from = from
        self.to = end
    }
}
