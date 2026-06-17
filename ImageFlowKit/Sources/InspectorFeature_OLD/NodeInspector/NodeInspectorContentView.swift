import SwiftUI

class NodeInspectorContentView: ScrollableStackXView {

    private let context: InspectorContext

    lazy var nodeTitleRowView: NodeTitleRowView = {
        let view = NodeTitleRowView(icon: "plus", name: "Some Node", locked: false)
        return view
    }()

    lazy var nodeTypeRowView: NodeTypeRowView = {
        let view = NodeTypeRowView()
        view.context = self.context
        return view
    }()

    lazy var nodeInputsView: NodeInputsView = {
        let view = NodeInputsView(title: "Inputs", showPortButton: true)
        return view
    }()

    lazy var nodeOutputsView: NodeOutputsView = {
        let view = NodeOutputsView()
        return view
    }()

    lazy var nodeOptionsView: NodeInputsView = {
        let view = NodeInputsView(title: "Options", showPortButton: false)
        return view
    }()

    private lazy var _nodeTypeRowView: PropertyView = {
        PropertyView(self.nodeTypeRowView, configuration: .compact)
            .with(\.label, "Node Type")
            .with(\.connected, nil)
    }()

    init(_ context: InspectorContext) {
        self.context = context
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupViews() {
        super.setupViews()

        self.stackView.addView(self.nodeTitleRowView)
        self.stackView.addView(self._nodeTypeRowView)
        self.stackView.addView(self.nodeInputsView)
        self.stackView.addView(self.nodeOutputsView)
        self.stackView.addView(self.nodeOptionsView)
    }
}
