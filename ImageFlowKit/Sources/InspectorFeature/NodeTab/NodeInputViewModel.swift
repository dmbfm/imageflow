import Backend
import Combine
import Foundation
import Helpers
import SharedModels
import Values

@MainActor
final class NodeInputViewModel: RxEventHandler, WithRef {
    @PublishedEx var name: String = ""
    @PublishedEx var value: Value = .float(0)
    @PublishedEx var connected: Bool = false
    @PublishedEx var hasChanges: Bool = false
    @PublishedEx var semantics: ValueSemantics = .default
    @PublishedEx var hidePortButton: Bool = false

    var disabled: AnyPublisher<Bool, Never> {
        self.$connected.map({ $0 }).eraseToAnyPublisher()
    }

    var index: Int = 0
    var node: UUID = .init()
    var cancellables: Set<AnyCancellable> = []
    var context: InspectorContext?

    enum Event {
        case valueChange(Change<Value>)
        case restoreButtonClicked
        case portButtonClicked
        case openAssetPicker
    }

    init() {}

    init(
        _ node: UUID,
        input: FlowNode.Input,
        schema: NodeInputSchema,
        context: InspectorContext? = nil,
        hidePortButton: Bool = false
    ) {
        self.context = context
        self.hidePortButton = hidePortButton
        self.update(node, input, schema, hidePortButton)
    }

    func receive(event: Event) {
        switch event {
        case .valueChange(let change):
            if self.value != change.newValue || change.commit && (change.oldValue != change.newValue) {
                self.context?.coordinator?.perform(
                    userAction: .setNodeInputValue(
                        port: .init(node: self.node, index: self.index),
                        newValue: change.newValue,
                        oldValue: change.oldValue,
                        undo: change.commit
                    )
                )
            }
        case .restoreButtonClicked:
            self.context?.coordinator?.perform(
                userAction: .restoreNodeInputDefaultValue(.init(node: self.node, index: self.index))
            )
        case .portButtonClicked:
            self.context?.coordinator?.perform(
                userAction: .selectNodesConnectedToPort(.init(node: self.node, port: .input(self.index)))
            )
        case .openAssetPicker:
            self.context?.coordinator?.perform(
                userAction: .openAssetPicker(
                    node: self.node,
                    portIndex: self.index,
                    kind: {
                        switch self.value {
                        case .image(_): .image
                        case .lut(_): .lut
                        default: .image
                        }
                    }()
                )
            )
        }
    }

    func titleForAsset(_ id: UUID) -> String? {
        self.context?.coordinator?.assetTitle(id)
    }

    func update(_ node: UUID, _ input: FlowNode.Input, _ schema: NodeInputSchema, _ hidePortButton: Bool = false) {

        if self.name != input.label {
            self.name = input.label
        }

        if self.value != input.value {
            self.value = input.value
        }

        if self.connected != input.connected {
            self.connected = input.connected
        }

        self.hasChanges = input.value != (schema.defaultValue ?? schema.type.defaultValue)

        if self.semantics != schema.semantics {
            self.semantics = schema.semantics
        }

        if self.index != input.index {
            self.index = input.index
        }

        if self.node != node {
            self.node = node
        }

        if self.hidePortButton != hidePortButton {
            self.hidePortButton = hidePortButton
        }
    }
}
