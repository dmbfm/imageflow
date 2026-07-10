import Combine
import ComponentKit
import Helpers
import SharedModels
import Values
import XKit

final class NodeTabView: XView, Rx {

    var vm: NodeTabViewModel

    var cancellables: Set<AnyCancellable> = []

    lazy var contentUnavailableView: NodeTabContentUnavailableView = {
        NodeTabContentUnavailableView()
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    lazy var stackView: VScrollView = {
        VScrollView(views: [], spacing: 16)
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
        NodeInputsView(self.vm.inputs)
    }()

    lazy var nodeOptionsView: NodeInputsView = {
        NodeInputsView(self.vm.options)
    }()

    lazy var nodeControlsView: NodeInputsView = {
        NodeInputsView(self.vm.controls)
    }()

    lazy var nodeOutputsView: NodeOutputsView = {
        NodeOutputsView(self.vm.outputs)
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
        self.stackView.constraintToFillSuperview(insets: .init(top: 0, left: 0, bottom: 12, right: 0))

        self.stackView.addView(Padded(self.nodeTitleView, insets: .init(top: 4, left: 0, bottom: 0, right: 0)))
        self.stackView.addView(Box(inspectorBlockWithView: self.nodeTypeView))
        self.stackView.addView(self.nodeControlsView)
        self.stackView.addView(self.nodeInputsView)
        self.stackView.addView(self.nodeOptionsView)
        self.stackView.addView(self.nodeOutputsView)
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

        self.nodeOptionsView.rx(self.vm.options.$inputs.map({ $0.isEmpty }), kp: \.isHidden)
        self.nodeControlsView.rx(self.vm.controls.$inputs.map({ $0.isEmpty }), kp: \.isHidden)
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

#Preview("Gaussian Blur Node") {
    NodeTabView(
        .init(
            {
                let flow = Flow()
                let id = flow.addNode(.init(kind: .coreImageFilterNode(.blur(.CIGaussianBlur))), at: .zero)
                flow.selection = [id!]
                return flow
            }(),
            .dummy
        )
    )
    .constrainingWidth(toConstant: 320)
    .constrainingHeight(toConstant: 300)
    .withContentHuggingPriority(.defaultLow - 10, for: .vertical)
    .withBorder(.systemGray.withAlphaComponent(0.2))
}
