import Combine
import Helpers
import SharedModels
import XKit

@MainActor
final class NodeTabViewModel: RxEventHandler {

    // MARK: - Published Properties

    @Published var route: Route = .contentUnavailable
    @Published var name: String = ""
    @Published var icon: String = ""
    @Published var locked: Bool = false

    // MARK: - Other Properties

    var currentNode: FlowNode? = nil {
        didSet {
            if self.currentNode != oldValue {
                self.currentNodeDidChange()
            }
        }
    }

    var cancellables: Set<AnyCancellable> = []
    let flow: Flow
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

    init(_ flow: Flow, _ context: any InspectorContext) {
        self.flow = flow
        self.context = context

        self.setupObservers()
    }

    // MARK: - Model Observation

    var selectionWhenUnlockedPublisher: AnyPublisher<Set<UUID>, Never> {
        self.flow.selectionDidChangePublisher
            .print("selectionWhenUnlockedPublisher")
            .filter({ [unowned self] _ in !self.locked })
            .eraseToAnyPublisher()
    }

    func setupObservers() {
        self.observeSelection()
        self.observeNodes()
    }

    func observeSelection() {
        self.selectionWhenUnlockedPublisher.sink { [unowned self] selection in
            self.setRoute(selection.isEmpty ? .contentUnavailable : .node)
        }.store(in: &self.cancellables)

        self.selectionWhenUnlockedPublisher.sink { [unowned self] selection in
            switch (self.currentNode, selection) {
            case (.some(_), []), (.none, []):
                self.setCurrentNode(nil)
            case (.some(let node), let selection) where selection.contains(node.id):
                break
            case (.some(_), _), (.none, _):
                self.pickNewNodeFromSelection()
            }
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

    // MARK: - State Mutation

    func setRoute(_ route: Route) {
        self.route = route
    }

    func setCurrentNode(_ node: FlowNode?) {
        self.currentNode = node
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
    }

    // MARK: - Events

    enum Event {
        case editName(String)
    }

    func receive(event: Event) {
        switch event {
        case .editName(let newName):
            self.updateNodeName(newName)
        }
    }

    // MARK: - Model Updates

    func updateNodeName(_ newName: String) {
        guard let node = self.currentNode else { return }
        self.flow.setNodeName(id: node.id, newValue: newName, undoManager: self.context.undoManager)
    }
}
