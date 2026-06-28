import Combine
import Foundation
import Helpers
import SharedModels

@MainActor
final class NodeOutputsViewModel: WithRef {
    @PublishedEx var title = "Outputs"
    @PublishedEx var outputs: [NodeOutputViewModel] = []

    var context: InspectorContext?

    func update(_ node: UUID, _ nodeOutputs: [FlowNode.Output]) {
        for index in 0..<min(self.outputs.count, nodeOutputs.count) {
            self.outputs[index].update(node, index, nodeOutputs[index])
        }

        if nodeOutputs.count > self.outputs.count {
            for index in self.outputs.count..<nodeOutputs.count {
                let output = nodeOutputs[index]
                self.outputs.append(
                    NodeOutputViewModel(
                        node,
                        output.index,
                        name: output.label,
                        connected: output.connected,
                        type: output.type.displayName,
                        context: self.context,
                    )
                )
            }
        } else if nodeOutputs.count < self.outputs.count {
            self.outputs.remove(atOffsets: .init(nodeOutputs.count..<self.outputs.count))
        }
    }
}
