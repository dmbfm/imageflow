import Backend
import Combine
import Helpers
import SharedModels
import Values
import XKit

struct OutputModel: Equatable {}

@MainActor
final class NodeTabViewModel: RxEventHandler, WithRef {

    // MARK: - Published Properties

    @PublishedEx var route: Route = .contentUnavailable
    @PublishedEx var name: String = ""
    @PublishedEx var icon: String = ""
    @PublishedEx var locked: Bool = false { didSet { self.lockedDidChange() } }
    @PublishedEx var typeName: String = ""
    @PublishedEx var typeOptions: [String] = []

    @PublishedEx var inputs: NodeInputsViewModel  // = .init().with(\.title, "Inputs")
    @PublishedEx var options: NodeInputsViewModel  //= .init().with(\.title, "Options")
    @PublishedEx var controls: NodeInputsViewModel  // = .init().with(\.title, "")
    @PublishedEx var outputs: NodeOutputsViewModel

    // MARK: - Other Properties

    var currentNode: FlowNode? = nil {
        didSet {
            if self.currentNode != oldValue {
                self.currentNodeDidChange()
            }
        }
    }

    var cancellables: Set<AnyCancellable> = []
    let flow: SharedModels::Flow
    let context: InspectorContext

    // MARK: - Types

    enum Route {
        case contentUnavailable
        case node

        var isNode: Bool {
            self == .node
        }

        var isContentUnavailable: Bool {
            self == .contentUnavailable
        }
    }

    // MARK: - Initialization

    init(_ flow: SharedModels::Flow, _ context: any InspectorContext) {
        self.flow = flow
        self.context = context
        self.inputs = .init().with(\.context, context).with(\.title, "Inputs")
        self.options = .init().with(\.context, context).with(\.title, "Options").with(\.hidePortButton, true)
        self.controls = .init().with(\.context, context).with(\.title, "").with(\.hidePortButton, true)
        self.outputs = .init().with(\.context, context).with(\.title, "Outputs")

        self.setupObservers()
    }

    // MARK: - View-related

    func nodeContextMenu() -> XMenu? {
        self.currentNode.flatMap({ self.context.nodeContextMenuProvider($0.id) })
    }

    // MARK: - Model Observation

    var selectionWhenUnlockedPublisher: AnyPublisher<Set<UUID>, Never> {
        self.flow.selectionDidChangePublisher
            .filter({ [unowned self] _ in !self.locked })
            .eraseToAnyPublisher()
    }

    func setupObservers() {
        self.observeSelection()
        self.observeNodes()
    }

    func observeSelection() {
        self.selectionWhenUnlockedPublisher.sink { [unowned self] _ in
            self.selectionDidChange()
        }.store(in: &self.cancellables)
    }

    func observeNodes() {
        self.flow.nodesDidChangePublisher.sink { [unowned self] in
            self.nodesDidChange()
        }.store(in: &self.cancellables)
    }

    func nodesDidChange() {
        guard let node = self.currentNode, let newValue = self.flow.nodes[node.id] else { return }
        self.setCurrentNode(newValue)
    }

    func selectionDidChange() {
        self.setRoute(self.flow.selection.isEmpty ? .contentUnavailable : .node)

        switch (self.currentNode, self.flow.selection) {
        case (.some(_), []), (.none, []):
            self.setCurrentNode(nil)
        case (.some(let node), let selection) where selection.contains(node.id):
            break
        case (.some(_), _), (.none, _):
            self.pickNewNodeFromSelection()
        }
    }

    // MARK: - State

    func setRoute(_ route: Route) {
        self.route = route
    }

    func setCurrentNode(_ node: FlowNode?) {
        self.currentNode = node
    }

    func toggleLocked() {
        self.locked.toggle()
    }

    func pickNewNodeFromSelection() {
        guard let id = self.flow.selection.first else {
            logger.warning("Empty selection!")
            return
        }

        guard let node = self.flow.nodes[id] else {
            logger.warning("Node '\(id)' not found.")
            return
        }

        self.currentNode = node
    }

    func currentNodeDidChange() {
        guard let node = self.currentNode else { return }

        if self.name != node.name {
            self.name = node.name
        }

        if self.icon != node.kind.icon {
            self.icon = node.kind.icon
        }

        if self.typeName != node.kind.displayName {
            self.typeName = node.kind.displayName
        }

        let typeOptions = node.variations.map({ $0.displayName })
        if self.typeOptions != typeOptions {
            self.typeOptions = typeOptions
        }

        self.inputs.update(
            node.id,
            zip(node.inputs, node.schema.inputs)
                .filter({ (input, schema) in schema.editorPlacement.inspector == .inputs })
        )

        self.options.update(
            node.id,
            zip(node.inputs, node.schema.inputs)
                .filter({ (input, schema) in schema.editorPlacement.inspector == .options })
        )

        self.controls.update(
            node.id,
            zip(node.inputs, node.schema.inputs)
                .filter({ (input, schema) in schema.editorPlacement.inspector == .controls })
        )

        self.outputs.update(node.id, node.outputs)
    }

    func lockedDidChange() {
        if !self.locked {
            self.selectionDidChange()
        }
    }

    // MARK: - Events

    enum Event {
        case editName(String)
        case lockButtonClick
        case nodeTypeSelected(Int)
    }

    func receive(event: Event) {
        switch event {
        case .editName(let newName):
            self.updateNodeName(newName)
        case .lockButtonClick:
            self.toggleLocked()
        case .nodeTypeSelected(let index):
            self.nodeTypeSelected(index)
        }
    }

    // MARK: - Model Updates

    func updateNodeName(_ newName: String) {
        guard let node = self.currentNode else { return }
        self.flow.setNodeName(id: node.id, newValue: newName, undoManager: self.context.undoManager)
    }

    func nodeTypeSelected(_ index: Int) {
        guard let node = self.currentNode else { return }
        if node.variations.indices.contains(index) {
            let newKind = node.variations[index]
            if newKind != node.kind {
                self.context.coordinator?.perform(userAction: .convertNode(node.id, newKind))
            }
        }
    }
}

extension NodeTabViewModel {
    struct InputModel: Equatable {
        public var name: String = ""
        // public var node: UUID = .init()
        public var index: Int = 0
        public var value: Value = .float(0)
        public var connected: Bool = false
        public var semantics: ValueSemantics = .default
        public var placement: NodeInputSchema.EditorPlacement.Inspector

        init(input: FlowNode.Input, schema: NodeInputSchema) {
            self.name = input.label
            self.index = input.index
            self.value = input.value
            self.connected = input.connected
            self.semantics = schema.semantics
            self.placement = schema.editorPlacement.inspector
        }
    }
}

extension FlowNode {
    var inputModels: [NodeTabViewModel.InputModel] {
        zip(self.inputs, self.schema.inputs).map({ (input, schema) in
            .init(input: input, schema: schema)
        })
    }
}
