import Foundation

extension Backend {
    public struct NodeImpl {
        
        public let schema: NodeSchema
        
        private let runImpl: (inout Backend.Node, NodeContext) async -> ()
        
        public init(schema: NodeSchema, runImpl: @escaping (inout Backend.Node, NodeContext) async -> ()) {
            self.schema = schema
            self.runImpl = runImpl
        }
        
        public func run(_ node: inout Backend.Node, _ context: NodeContext) async {
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
}
    
    
extension Backend.NodeImplProvider where Param == Void {
    static func impl() -> Backend.NodeImpl {
            Self.impl(())
    }
}
