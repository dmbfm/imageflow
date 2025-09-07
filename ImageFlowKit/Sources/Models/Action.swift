import Backend
import Foundation

@MainActor
public final class Dispatcher: ObservableObject {

    public init() {}

    private var listener: (@MainActor (Action) -> ())? = nil

    public func send(_ action: Action) {
        self.listener?(action)
    }

    public func listen(_ listener: @escaping @MainActor (Action) -> ()) {
        self.listener = listener
    }
}

public enum Action: Sendable {
    case addNode(AddNode)
}

extension Action {
    public struct AddNode: Sendable {
        public var id: UUID
        public var kind: NodeKind
        public var position: Position

        public enum Position: Sendable {
            case center
            case point(CGPoint)
        }

        public init(id: UUID, kind: NodeKind, position: Position) {
            self.id = id
            self.kind = kind
            self.position = position
        }
    }

}
