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
            logger.debug("vm didSet: \("\(oldValue)") -> \("\(self.vm)")")
            if self.vm != oldValue {
                self.updateView()
            }
        }
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

    override func viewDidLoad() {
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
    }

    // MARK: - State updates

    func selectionDidChange() {
        self.vm.update(.selection(nodes: self.flow.nodes, selection: self.flow.selection))
    }

    func nodesDidChange() {

    }

    // MARK: - View updates

    func updateView() {
        self.updateRoute()
        self.updateNodeTitleRowView()
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

#Preview("Empty", traits: .fixedLayout(width: 280, height: 600)) {
    NodeInspectorController(
        {
            let flow = Flow()
            return flow
        }(),
        .init(MockGlobalCoordinator())
    )
}

#Preview("Single Node Selected", traits: .fixedLayout(width: 280, height: 600)) {
    NodeInspectorController(
        {
            let flow = Flow()
            let node = FlowNode(kind: .valueNode(.float))
            flow.addNode(node, at: .zero)
            flow.selection = [node.id]
            return flow
        }(),
        .init(MockGlobalCoordinator())
    )
}
