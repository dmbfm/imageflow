import Backend
import Combine
import ContextMenus
import Helpers
import SharedModels
import SwiftUI
import Values
import XKit

class NodeInspectorController: XViewController {

    // MARK: - Properties

    let flow: SharedModels::Flow
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

    lazy var context: InspectorContext = {
        .init(
            onNodeTypePickItem: { [weak self] value in
                self?.nodeTypeRowView(didPickItem: value)
            },
            onPortClick: { [weak self] in
                logger.error("TODO: onPortClick")
            },
            onRestoreButtonClick: { [weak self] in
                logger.error("TODO: onRestoreButtonClick")
            }
        )
    }()

    // MARK: - Views

    lazy var emptyView: XView = {
        let view = NodeInspectorEmtpyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var contentView: NodeInspectorContentView = {
        let view = NodeInspectorContentView(self.context)
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

    var nodeOptionsView: NodeInputsView {
        self.contentView.nodeOptionsView
    }

    var nodeOutputsView: NodeOutputsView {
        self.contentView.nodeOutputsView
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

        // self.nodeTypeRowView.didPickItem = { [weak self] value in
        //     self?.nodeTypeRowView(didPickItem: value)
        // }
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
        self.update(inputsView: self.nodeInputsView, placement: .inputs)
        self.update(inputsView: self.nodeOptionsView, placement: .options)
        self.updateOutputs()
        // self.updateOptions()
    }

    func onNodeOutputControlEvent(_ port: Int, _ event: NodeOutputControlEvent) {
        switch event {
        case .portButtonClicked:
            guard let node = self.node else { return }
            self.flow.select(nodeConnectedToNode: node.id, atOutputPort: port)
        }
    }

    func updateOutputs() {
        guard let node = self.vm.node else { return }

        let needsRepopulate =
            node.outputs.count != self.nodeOutputsView.outputViews.count

        if needsRepopulate {
            self.nodeOutputsView.removeAllOutputViews()

            for output in node.outputs {
                let view = NodeOutputView()
                view.context = .init(onPortClick: { [weak self] in
                    self?.onNodeOutputControlEvent(output.index, .portButtonClicked)
                })
                view.name = output.label
                view.connected = output.connected
                view.type = output.type
                self.nodeOutputsView.addOutputView(view)
            }

            return
        }

        for (idx, view) in self.nodeOutputsView.outputViews.enumerated() {
            if view.name != node.outputs[idx].label {
                view.name = node.outputs[idx].label
            }
            if view.connected != node.outputs[idx].connected {
                view.connected = node.outputs[idx].connected
            }
            if view.type != node.outputs[idx].type {
                view.type = node.outputs[idx].type
            }
        }
    }

    func update(inputsView: NodeInputsView, placement: NodeInputSchema.EditorPlacement.Inspector) {
        guard let node = self.vm.node else { return }
        let inputs = node.inputs(withInspectorPlacement: placement)

        inputsView.isHidden = inputs.isEmpty

        var needsRepopulate: Bool {
            var differentCount: Bool { inputs.count != inputsView.inputViews.count }
            var differentTypes: Bool {
                zip(node.inputs, inputsView.inputViews).first(where: { (a, b) in a.value.type != b.value.type })
                    != nil
            }

            return differentCount || differentTypes
        }

        if needsRepopulate {
            inputsView.removeAllInputViews()

            for input in inputs {
                let view = self.view(
                    forInput: input,
                    schema: node.schemaWithFallback(forInput: input.index)
                )
                view.portIndex = input.index
                view.hasChanges = node.hasChanges(forInput: input.index)
                view.delegate = self
                inputsView.addInputView(view)
            }

            return
        }

        for (idx, view) in inputsView.inputViews.enumerated() {
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

    func view(forInput input: FlowNode.Input, schema: NodeInputSchema) -> any NodeInputControlView {
        switch input.value.type {
        case .matrix2x2, .matrix3x3, .matrix5x5, .matrix7x7:
            NodeMatrixInputControlView(
                label: input.label,
                value: input.value,
                connected: input.connected
            )
        case .string:
            NodeStringInputControlView(
                label: input.label,
                value: input.value,
                connected: input.connected
            )
        case .rect:
            NodeRectInputControlView(
                label: input.label,
                value: input.value,
                connected: input.connected
            )
        case .vector2, .vector3, .vector4:
            NodeVectorInputControlView(
                label: input.label,
                value: input.value,
                connected: input.connected
            )
        case .image, .lut:
            NodeAssetInputControlView(
                label: input.label,
                value: input.value,
                connected: input.connected
            )
        case .color4:
            NodeColorInputControlView(label: input.label, value: input.value, connected: input.connected)
        case .int:
            switch schema.semantics {
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
            switch schema.semantics {
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
        case .bool:
            NodeBoolInputControlView(
                label: input.label,
                value: input.value,
                connected: input.connected
            )
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

extension NodeInspectorController: NodeInputControlDelegate {
    func nodeInputControl(_ sender: any NodeInputControlView, valueDidChange change: ValueChange) {
        guard let node = self.node else { return }
        self.flow.setNodeValue(
            id: node.id,
            index: sender.portIndex,
            oldValue: change.oldValue,
            newValue: change.newValue,
            undoManager: change.commit ? self.undoManager : nil
        )
        if change.commit {
            self.coordinator.undoService.setActionName(
                "\(change.newValue.type.displayName) Value Change",
                icon: .systemIconValue,
            )
        }
    }

    func nodeInputControl(_ sender: any NodeInputControlView, displayNameForAsset asset: UUID) -> String? {
        self.coordinator.assetTitle(asset)
    }

    func nodeInputControlPortButtonClicked(_ sender: any NodeInputControlView) {
        guard let node = self.node else { return }
        self.flow.select(nodeConnectedToNode: node.id, atInputPort: sender.portIndex)
    }

    func nodeInputControlRestoreButtonClicked(_ sender: any NodeInputControlView) {
        guard let node = self.node else { return }
        self.flow.restoreDefaultValue(id: node.id, index: sender.portIndex, undoManager: self.undoManager)
        self.coordinator.undoService.setActionName("Restore Default Value", icon: .systemIconValue)
    }

    func nodeInputControlOpenAssetPicker(_ sender: any NodeInputControlView) {
        let port = sender.portIndex
        guard let node = self.node,
            let assetKind = node.inputs[tryGetAt: port]?.value.type.assetKind
        else { return }
        self.coordinator.perform(userAction: .openAssetPicker(node: node.id, portIndex: port, kind: assetKind))
    }
}

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
