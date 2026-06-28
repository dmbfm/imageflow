import Combine
import Foundation
import Helpers
import SharedModels

@MainActor
final class NodeOutputViewModel: WithRef, RxEventHandler {
    @PublishedEx var name: String = "output"
    @PublishedEx var connected: Bool = false
    @PublishedEx var type: String = "Float"

    var index: Int = 0
    var node: UUID = .init()
    var context: InspectorContext?
    var cancellables: Set<AnyCancellable> = []

    init(
        _ node: UUID,
        _ index: Int,
        name: String = "output",
        connected: Bool = false,
        type: String = "Float",
        context: InspectorContext? = nil
    ) {
        self.index = index
        self.node = node
        self.name = name
        self.connected = connected
        self.type = type
        self.context = context
    }

    func update(_ node: UUID, _ index: Int, _ output: FlowNode.Output) {

        if self.node != node {
            self.node = node
        }

        if self.index != index {
            self.index = index
        }

        if self.name != output.label {
            self.name = output.label
        }

        if self.connected != output.connected {
            self.connected = output.connected
        }
        if self.type != output.type.displayName {
            self.type = output.type.displayName
        }
    }

    enum Event {
        case portButtonClicked
    }

    func receive(event: Event) {
        switch event {
        case .portButtonClicked:
            self.context?.coordinator?.perform(
                userAction: .selectNodesConnectedToPort(.init(node: self.node, port: .output(self.index)))
            )
        }
    }
}
