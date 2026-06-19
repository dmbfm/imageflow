import Combine
import ComponentKit
import Helpers
import SharedModels
import XKit

final class NodeInputsView: XView, Rx, WithRef {

    var cancellables: Set<AnyCancellable> = []

    lazy var stackView: VStack = {
        VStack(
            alignment: .fill,
            spacing: 8,
            views: [
                Label("Inputs")
                    .with(\.font, .systemFont(ofSize: XFont.systemFontSize, weight: .bold))
            ]
        )
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    var controls: [NodeInputControl] = []

    init() {
        super.init(frame: .zero)

        self.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class NodeTabView: XView, Rx {

    var vm: NodeTabViewModel

    var cancellables: Set<AnyCancellable> = []

    lazy var contentUnavailableView: NodeTabContentUnavailableView = {
        NodeTabContentUnavailableView()
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    lazy var stackView: VStack = {
        VStack(alignment: .fill, spacing: 16, views: [])
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    lazy var contentView: RXView = {
        let view = RXView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var nodeTitleView: NodeTitleView = {
        let view = NodeTitleView(icon: "questionmark", name: "", locked: false)
        view.nodeContextMenuProvider = { [weak self] in
            self?.vm.nodeContextMenu()
        }
        return view
    }()

    lazy var nodeTypeView: NodeTypeView = {
        NodeTypeView()
    }()

    lazy var nodeInputsView: NodeInputsView = {
        NodeInputsView()
    }()

    init(_ vm: NodeTabViewModel) {
        self.vm = vm

        super.init(frame: .zero)

        self.setupView()
        self.setupBindings()
        self.setupNotifications()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.addSubview(self.contentUnavailableView)
        self.addSubview(self.contentView)

        self.contentView.constraintToFillSuperview()
        self.contentUnavailableView.constraintToFillSuperview()

        self.contentView.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview()

        self.stackView.addView(self.nodeTitleView)
        self.stackView.addView(Box(inspectorBlockWithView: self.nodeTypeView))
        self.stackView.addView(self.nodeInputsView)
    }

    func setupBindings() {
        let route = self.vm.$route

        self.contentUnavailableView.rx(route.map(\.isNode), kp: \.isHidden)
        self.contentView.rx(route.map(\.isContentUnavailable), kp: \.isHidden)

        self.nodeTitleView.rx(self.vm.$name, kp: \.name)
        self.nodeTitleView.rx(self.vm.$icon, kp: \.icon)
        self.nodeTitleView.rx(self.vm.$locked, kp: \.locked)

        self.nodeTypeView.rx(self.vm.$typeName, kp: \.name)
        self.nodeTypeView.rx(self.vm.$typeOptions, kp: \.options)
    }

    func setupNotifications() {
        self.vm.handleEvents(from: self.nodeTitleView.didEditNodeName.map({ .editName($0) }))
        self.vm.handleEvents(from: self.nodeTitleView.lockButtonPublisher.map({ .lockButtonClick }))
        self.vm.handleEvents(from: self.nodeTypeView.selectedIndexPublisher.map({ .nodeTypeSelected($0) }))
    }

    @objc func rename(_ sender: Any?) {
        if self.isHidden { return }
        self.nodeTitleView.nameTextField.isFocusable = true
        self.nodeTitleView.nameTextField.becomeFirstResponder()
        self.nodeTitleView.nameTextField.isFocusable = false
    }
}

#Preview("Content Unavailable") {
    NodeTabView(.init(.init(), .dummy))
        .constrainingWidth(toConstant: 320)
}

#Preview("Float Node") {
    NodeTabView(
        .init(
            {
                let flow = Flow()
                let id = flow.addNode(.init(kind: .valueNode(.float)), at: .zero)
                flow.selection = [id!]
                return flow
            }(),
            .dummy
        )
    )
    .constrainingWidth(toConstant: 320)
}

#Preview("Add Node") {
    NodeTabView(
        .init(
            {
                let flow = Flow()
                let id = flow.addNode(.init(kind: .math(.addNode(.float))), at: .zero)
                flow.selection = [id!]
                return flow
            }(),
            .dummy
        )
    )
    .constrainingWidth(toConstant: 320)
}
