import Combine
import Helpers
import SharedModels
import XKit

@MainActor
final class NodeTabContentViewModel {

    @Published var name: String = ""
    @Published var locked: Bool = false

    var currentNode: FlowNode? {
        didSet {
            if self.currentNode != oldValue {
                self.currentNodeDidChange()
            }
        }
    }

    let flow: Flow

    private var cancellables: Set<AnyCancellable> = []

    init(_ flow: Flow) {
        self.flow = flow

        self.flow.nodesDidChangePublisher.sink { [weak self] in
            self?.nodesDidChange()
        }.store(in: &self.cancellables)

        self.flow.selectionDidChangePublisher.sink { [weak self] in
            self?.selectionDidChange()
        }.store(in: &self.cancellables)
    }

    func nodesDidChange() {
        logger.info("nodesDidChange!")
    }

    func selectionDidChange() {
        guard !self.locked else { return }

        if let node = self.currentNode {
            if self.flow.selection.contains(node.id) {
                return
            } else {
                self.pickNewNodeFromSelection()
            }
        } else {
            self.pickNewNodeFromSelection()
        }
    }

    func pickNewNodeFromSelection() {
        guard !self.locked else { return }

        guard let newNodeID = self.flow.selection.first, let newNode = self.flow.nodes[newNodeID] else {
            self.currentNode = nil
            return
        }

        self.currentNode = newNode
    }

    func currentNodeDidChange() {
        guard let node = self.currentNode else { return }

        if self.name != node.name {
            self.name = node.name
        }
    }
}
