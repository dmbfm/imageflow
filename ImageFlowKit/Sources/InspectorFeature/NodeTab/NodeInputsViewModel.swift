import Backend
import Combine
import Foundation
import Helpers
import SharedModels

@MainActor
final class NodeInputsViewModel: WithRef {
    @PublishedEx var title: String = "Inputs"
    @PublishedEx var inputs: [NodeInputViewModel] = []

    var context: InspectorContext?

    func update(_ node: UUID, _ nodeInputs: [(FlowNode.Input, NodeInputSchema)]) {

        for index in 0..<min(self.inputs.count, nodeInputs.count) {
            self.inputs[index].update(node, nodeInputs[index].0, nodeInputs[index].1)
        }

        if nodeInputs.count > self.inputs.count {
            for index in self.inputs.count..<nodeInputs.count {
                self.inputs.append(
                    NodeInputViewModel(
                        node,
                        input: nodeInputs[index].0,
                        schema: nodeInputs[index].1,
                        context: self.context
                    )
                )
            }
        } else if nodeInputs.count < self.inputs.count {
            self.inputs.remove(atOffsets: .init(nodeInputs.count..<self.inputs.count))
        }
    }
}
