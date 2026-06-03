import Combine
import ContextMenus
import Helpers
import SharedModels
import SwiftUI
import XKit

class NodeInspectorController: XViewController {

    // MARK: - Properties

    let flow: Flow
    let coordinator: GlobalCoordinator

    private var cancellables: Set<AnyCancellable> = []

    private var vm: NodeInspectorViewModel = .empty {
        didSet {
            if self.vm != oldValue {
                self.updateView()
            }
        }
    }

    var node: FlowNode? {
        self.vm.node
    }

    // MARK: - Views

    lazy var emptyView: XView = {
        let view = NodeInspectorEmtpyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var contentView: NodeInspectorContentView = {
        let view = NodeInspectorContentView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var nodeTitleRowView: NodeTitleRowView {
        self.contentView.nodeTitleRowView
    }

    var nodeTypeRowView: NodeTypeRowView {
        self.contentView.nodeTypeRowView
    }

    var nodeInputsView: NodeInputsView {
        self.contentView.nodeInputsView
    }

    // MARK: - Init

    init(_ flow: Flow, _ coordinator: GlobalCoordinator) {
        self.flow = flow
        self.coordinator = coordinator

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    override func loadView() {
        self.view = .init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
        self.setupObservers()
        self.selectionDidChange()
        self.updateView()
    }

    func setupViews() {
        for subview in [emptyView, contentView] {
            self.view.addSubview(subview)
            NSLayoutConstraint.activate([
                subview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                subview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                subview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                subview.topAnchor.constraint(equalTo: self.view.topAnchor),
            ])
        }
    }

    func setupObservers() {
        self.flow.selectionDidChangePublisher.sink { [weak self] in
            self?.selectionDidChange()
        }.store(in: &self.cancellables)

        self.flow.nodesDidChangePublisher.sink { [weak self] in
            self?.nodesDidChange()
        }.store(in: &self.cancellables)

        self.nodeTitleRowView.delegate = self

        self.nodeTypeRowView.didPickItem = { [weak self] value in
            self?.nodeTypeRowView(didPickItem: value)
        }
    }

    // MARK: - State updates

    func selectionDidChange() {
        self.vm.update(.selection(nodes: self.flow.nodes, selection: self.flow.selection))
    }

    func nodesDidChange() {
        self.vm.update(.nodesDidChange(nodes: self.flow.nodes))
    }

    func nodeTypeRowView(didPickItem item: String) {
        if let node = self.node, let newKind = node.variations.first(where: { $0.displayName == item }) {
            self.coordinator.perform(userAction: .convertNode(node.id, newKind))
        }
    }

    // MARK: - View updates

    func updateView() {
        self.updateRoute()
        self.updateNodeTitleRowView()
        self.updateNodeTypeRowView()
        self.updateInputs()
    }

    func onNodeInputControlEvent(_ port: Int, _ event: NodeInputControlEvent) {
        switch event {
        case .portButtonClicked:
            guard let node = self.node else { return }
            self.flow.select(nodeConnectedToNode: node.id, atInputPort: port)
        case .restoreButtonClicked:
            guard let node = self.node else { return }
            self.flow.restoreDefaultValue(id: node.id, index: port, undoManager: self.undoManager)
            self.undoManager?.setActionName("Restore Default Value")
        case .valueDidChange(let change):
            guard let node = self.node else { return }
            self.flow.setNodeValue(
                id: node.id,
                index: port,
                oldValue: change.oldValue,
                newValue: change.newValue,
                undoManager: change.commit ? self.undoManager : nil
            )
            if change.commit {
                self.undoManager?.setActionName("\(change.newValue.type.displayName) Value Change")
            }
        }
    }

    func updateInputs() {
        guard let node = self.vm.node else { return }

        let needsRepopulate =
            node.inputs.count != self.nodeInputsView.inputViews.count
            || zip(node.inputs, nodeInputsView.inputViews).first(where: { (a, b) in a.value.type != b.value.type })
                != nil

        if needsRepopulate {
            self.nodeInputsView.removeAllInputViews()

            for input in node.inputs {
                let view = self.view(forInput: input)
                view.context = .init(self, input.index)
                view.hasChanges = node.hasChanges(forInput: input.index)
                self.nodeInputsView.addInputView(view)
            }

            return
        }

        for (idx, view) in self.nodeInputsView.inputViews.enumerated() {
            if view.value != node.inputs[idx].value {
                view.value = node.inputs[idx].value
            }
            if view.connected != node.inputs[idx].connected {
                view.connected = node.inputs[idx].connected
            }
            let hasChanges = node.hasChanges(forInput: idx)
            if view.hasChanges != hasChanges {
                view.hasChanges = hasChanges
            }
        }
    }

    func updateNodeTitleRowView() {
        switch self.vm {
        case .content(node: let node, _, let locked):
            if self.nodeTitleRowView.name != node.name {
                self.nodeTitleRowView.name = node.name
            }
            if self.nodeTitleRowView.locked != locked {
                self.nodeTitleRowView.locked = locked
            }
            if self.nodeTitleRowView.icon != node.kind.icon {
                self.nodeTitleRowView.icon = node.kind.icon
            }
        case .empty:
            break
        }
    }

    func updateNodeTypeRowView() {
        if let node = self.node {
            self.nodeTypeRowView.vm = .init(
                value: node.kind.displayName,
                options: node.variations.map({ $0.displayName })
            )
        }
    }

    func updateRoute() {
        switch self.vm {
        case .empty:
            self.showEmptyView()
        case .content(_, _, _):
            self.showContentView()
        }
    }

    func showEmptyView() {
        if !self.contentView.isHidden {
            self.contentView.isHidden = true
        }
        if self.emptyView.isHidden {
            self.emptyView.isHidden = false
        }
    }

    func showContentView() {
        if self.contentView.isHidden {
            self.contentView.isHidden = false
        }
        if !self.emptyView.isHidden {
            self.emptyView.isHidden = true
        }
    }

    // MARK: - Input Views

    func view(forInput input: FlowNode.Input) -> any NodeInputControlView {
        switch input.value.type {
        case .int:
            switch input.semantics {
            case .integer(.picker(let options)):
                NodeIntegerOptionInputControlView(
                    label: input.label,
                    value: input.value,
                    connected: input.connected,
                    options: options
                )
            case .integer(.range(let range)):
                NodeIntegerInputControlView(
                    label: input.label,
                    value: input.value,
                    connected: input.connected,
                    range: range,
                    minValue: nil
                )
            case .integer(.partialRangeFrom(let minValue)):
                NodeIntegerInputControlView(
                    label: input.label,
                    value: input.value,
                    connected: input.connected,
                    range: nil,
                    minValue: minValue
                )
            default:
                NodeIntegerInputControlView(
                    label: input.label,
                    value: input.value,
                    connected: input.connected,
                    range: nil,
                    minValue: nil
                )
            }
        case .float:
            switch input.semantics {
            case .float(.angle(nil)):
                NodeAngleInputControlView(
                    label: input.label,
                    value: input.value,
                    connected: input.connected
                )
            case .float(.angle(.some(let range))):
                if abs(range.span - 2.0 * .pi) < 0.001 {
                    NodeAngleInputControlView(
                        label: input.label,
                        value: input.value,
                        connected: input.connected,
                    )
                } else {
                    NodeAngleInputControlView(
                        label: input.label,
                        value: input.value,
                        connected: input.connected,
                        range: range
                    )
                }
            case .float(.range(let range)):
                NodeFloatInputControlView(
                    label: input.label,
                    value: input.value,
                    connected: input.connected,
                    range: range
                )
            default:
                NodeFloatInputControlView(
                    label: input.label,
                    value: input.value,
                    connected: input.connected
                )
            }
        default:
            DummyInputControlView(
                label: input.label,
                value: input.value,
                connected: input.connected
            )
        }
    }

    // MARK: - Node Context Menu Actions

    @objc func delete(_ sender: Any?) {
        if let node = self.vm.node {
            self.coordinator.perform(userAction: .delete(.nodes([node.id])))
        }
    }

    @objc func cut(_ sender: Any?) {
        if let node = self.vm.node {
            self.coordinator.perform(userAction: .cut(.nodes([node.id])))
        }
    }

    @objc func rename(_ sender: Any?) {
        self.nodeTitleRowView.nameTextField.isFocusable = true
        self.view.window?.makeFirstResponder(self.nodeTitleRowView.nameTextField)
        self.nodeTitleRowView.nameTextField.isFocusable = false
    }
}

// MARK: - NodeTitleRowView.Delegate

extension NodeInspectorController: NodeTitleRowView.Delegate {
    func nodeTitleRowViewLockButtonClick(_: NodeTitleRowView) {
        self.vm.update(.toggleLock(nodes: self.flow.nodes))
    }

    func nodeTitleRowViewContextMenu() -> XMenu? {
        switch self.vm {
        case .content(node: let node, _, _):
            {
                let menu = NodeContextMenu.make(self.flow, node.id)
                if let menu {
                    for item in menu.items {
                        if item.action == #selector(NSText.delete(_:)) {
                            item.target = self
                        } else if item.action == #selector(NSText.cut(_:)) {
                            item.target = self
                        } else if item.action == #selector(ImageFlowResponding.rename(_:)) {
                            item.target = self
                        }
                    }
                    menu.items = menu.items.filter({ item in
                        if item.action == #selector(NSResponder.selectAll(_:)) {
                            return false
                        } else if item.action == #selector(NSText.paste(_:)) {
                            return false
                        }

                        return true
                    })
                }
                return menu
            }()
        default:
            nil
        }
    }

    func nodeTitleRowViewDidEditName(_ value: String) {
        switch self.vm {
        case .content(node: let node, _, _):
            self.flow.setNodeName(id: node.id, newValue: value, undoManager: self.undoManager)
        case .empty:
            break
        }
    }
}

fileprivate struct PreviewView: XViewRepresentable {

    func makeView(context: Context) -> some NSView {
        let flow = Flow()
        let node = FlowNode(kind: .valueNode(.float))
        flow.addNode(node, at: .zero)
        flow.selection = [node.id]
        context.coordinator.controller = NodeInspectorController(flow, .init(MockGlobalCoordinator()))
        return context.coordinator.controller.view
    }

    func updateView(_ view: ViewType, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        .init()
    }

    class Coordinator {
        var controller: NodeInspectorController!
    }
}

#Preview {
    VStack {
        PreviewView()
            .padding(10)
    }
    .frame(width: 300)
    // .frame(minWidth: 240)
}
