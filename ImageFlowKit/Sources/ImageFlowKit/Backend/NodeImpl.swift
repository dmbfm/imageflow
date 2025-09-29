import Foundation

public struct NodeImpl {

    public let schema: NodeSchema

    private let runImpl: (inout BackendNode, NodeContext) async -> ()

    public init(schema: NodeSchema, runImpl: @escaping (inout BackendNode, NodeContext) async -> ()) {
        self.schema = schema
        self.runImpl = runImpl
    }

    public func run(_ node: inout BackendNode, _ context: NodeContext) async {
        if self.schema.validate(node: node) != .ok {
            fatalError()
        }
        await self.runImpl(&node, context)
    }
}

protocol NodeImplProvider<Param> {
    associatedtype Param = ()
    static func impl(_ param: Param) -> NodeImpl
}

extension NodeImplProvider where Param == Void {
    static func impl() -> NodeImpl {
        Self.impl(())
    }
}
