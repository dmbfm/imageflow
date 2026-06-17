// import Combine
// import Helpers
// import SharedModels
// import XKit

// @MainActor
// final class NodeTabContentViewModel: EventSubscriber {

//     @Published var name: String = ""
//     @Published var icon: String = "questionmark"
//     @Published var locked: Bool = false

//     private var currentNode: FlowNode? {
//         didSet {
//             if self.currentNode != oldValue {
//                 self.currentNodeDidChange()
//             }
//         }
//     }

//     private let flow: Flow

//     private let context: InspectorContext

//     private var cancellables: Set<AnyCancellable> = []

//     private var undoManager: UndoManager? {
//         self.context.undoManager
//     }

//     enum Event {
//         case lockClick
//         case nameEdit(String)
//     }

//     init(_ flow: Flow, _ context: InspectorContext) {
//         self.flow = flow
//         self.context = context

//         self.flow.nodesDidChangePublisher.sink { [weak self] in
//             self?.nodesDidChange()
//         }.store(in: &self.cancellables)

//         self.flow.selectionDidChangePublisher.sink { [weak self] in
//             self?.selectionDidChange()
//         }.store(in: &self.cancellables)
//     }

//     func receive(event: Event) {
//         switch event {
//         case .lockClick:
//             self.locked.toggle()
//         case .nameEdit(let newName):
//             guard let node = self.currentNode else { return }
//             self.flow.setNodeName(id: node.id, newValue: newName, undoManager: self.undoManager)
//             break
//         }
//     }

//     func nodesDidChange() {
//         logger.info("nodesDidChange!")
//     }

//     func selectionDidChange() {
//         guard !self.locked else { return }

//         if let node = self.currentNode {
//             if self.flow.selection.contains(node.id) {
//                 return
//             } else {
//                 self.pickNewNodeFromSelection()
//             }
//         } else {
//             self.pickNewNodeFromSelection()
//         }
//     }

//     func pickNewNodeFromSelection() {
//         guard !self.locked else { return }

//         guard let newNodeID = self.flow.selection.first, let newNode = self.flow.nodes[newNodeID] else {
//             self.currentNode = nil
//             self.locked = false
//             return
//         }

//         self.currentNode = newNode
//     }

//     func currentNodeDidChange() {
//         guard let node = self.currentNode else { return }

//         if self.name != node.name {
//             self.name = node.name
//         }

//         if self.icon != node.kind.icon {
//             self.icon = node.kind.icon
//         }
//     }
// }
