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
