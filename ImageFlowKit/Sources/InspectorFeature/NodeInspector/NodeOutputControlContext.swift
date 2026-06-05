enum NodeOutputControlEvent {
    case portButtonClicked
}

@MainActor
struct NodeOutputControlContext {
    var index: Int

    private weak var controller: NodeInspectorController?

    init(_ controller: NodeInspectorController, _ index: Int) {
        self.controller = controller
        self.index = index
    }

    func emit(_ event: NodeOutputControlEvent) {
        self.controller?.onNodeOutputControlEvent(self.index, event)
    }
}
