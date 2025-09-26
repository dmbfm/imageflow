import Backend
import Foundation
import SwiftUI

public extension EnvironmentValues {
    @Entry var dispatch: ((Action) -> ())? = nil
}

public struct ActionUndoData {
    public weak var undoManager: UndoManager?
    public var title: String
}

public struct Dispatcher<A>: Equatable {

    public static func == (lhs: Dispatcher<A>, rhs: Dispatcher<A>) -> Bool {
        lhs.id == rhs.id
    }

    public var id: UUID = .init()
    public var dispatcher: (A) -> ()

    public init(_ dispatcher: @escaping (A) -> ()) {
        self.dispatcher = dispatcher
    }

    public func callAsFunction(_ action: A) {
        self.dispatcher(action)
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
