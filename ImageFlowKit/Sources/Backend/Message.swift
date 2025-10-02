import Foundation

public struct Message: Sendable {
    public var content: Content
    public var level: Level
    public var scope: Scope

    public enum Scope: Sendable {
        case global
        case node(UUID)
        case input(UUID, Int)
        case output(UUID, Int)
        case edge(Edge)
    }

    public enum Content: Sendable {
        case multipleEdgesAtSameInputPort
        case addInvalidEdge(Edge)
        case edgeInCycle
        case raw(String)
        case missingNode(UUID)
        case imageProvider(FlowImageProviderError)
        case invalidOutputPort(Int)
    }

    public enum Level: Sendable {
        case info
        case warning
        case error
    }

    public init(content: Content, scope: Scope = .global, level: Level = .info) {
        self.content = content
        self.level = level
        self.scope = scope
    }

    public static func error(content: Content, scope: Scope = .global) -> Self {
        .init(content: content, scope: scope, level: .error)
    }
}

struct NodeMessage: Sendable {
    var content: Message.Content
    var level: Message.Level
    var scope: Scope

    enum Scope: Sendable {
        case global
        case node
        case input(Int)
        case output(Int)

        func messageScope(_ id: UUID) -> Message.Scope {
            switch self {
            case .global: .global
            case .node: .node(id)
            case .input(let n): .input(id, n)
            case .output(let n): .output(id, n)
            }
        }
    }

    init(content: Message.Content, scope: NodeMessage.Scope = .node, level: Message.Level = .info) {
        self.content = content
        self.level = level
        self.scope = scope
    }

    func message(withNodeID id: UUID) -> Message {
        Message(content: self.content, scope: self.scope.messageScope(id), level: self.level)
    }
}

public final class MessageStore {
    var messages: [Message] = []

    public init() {}

    func message(_ message: Message) {
        self.messages.append(message)
    }

    func error(_ content: Message.Content, scope: Message.Scope = .global) {
        self.messages.append(.error(content: content, scope: scope))
    }
}
