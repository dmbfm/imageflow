import Foundation

public struct BackendFlow {

    public var nodes: [BackendNode] = []
    public var edges: [BackendEdge] = []
    public var imageProvider: any FlowImageProvider

    public init(nodes: [BackendNode] = [], edges: [BackendEdge] = [], _ imageProvider: some FlowImageProvider) {
        self.nodes = nodes
        self.edges = edges
        self.imageProvider = imageProvider
    }

    public init?(nodes: [BackendNode] = [], validatingEdges: [BackendEdge] = [], _ imageProvider: some FlowImageProvider) {
        fatalError("TODO: Implement this")
    }

    public mutating func run() async -> [Message] {
        // Storage for the messages generated during the run
        let messageStore = MessageStore()

        // Crate the graph
        let graph = FlowGraph(messageStore)

        // Add the nodes to the graph
        for node in self.nodes {
            graph.addNode(node.id)
        }

        // Add the edges to the graph
        for edge in self.edges {
            graph.addEdge(edge)
        }

        // Check if the graph is a DAG or if it has cycles
        if graph.detectCycles() == .hasCycles {
            return messageStore.messages
        }

        // Do a topological sort of the graph and go through each
        // node in the sorted list
        for nodeIndex in graph.sortedNodes()! {
            // For each input port
            for index in 0..<self.nodes[nodeIndex].inputs.count {
                // Get the edge incoming to that input port, if there is one
                if let edge = graph.incomindEdge(toNodeAtIndex: nodeIndex, inputPort: index) {
                    // Set the input value of the current node input to the output ot the connected node output port
                    self.nodes[nodeIndex].inputs[index] = self.nodes[edge.start.nodeIndex].outputs[edge.start.slot]
                }
            }

            // Execute the current node
            let context = NodeContext(
                id: self.nodes[nodeIndex].id,
                imageProvider: self.imageProvider,
                messageStore: messageStore
            )
            await self.nodes[nodeIndex].kind.impl.run(&self.nodes[nodeIndex], context)
        }

        return messageStore.messages
    }
}
