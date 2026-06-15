import SwiftUI

class NodeInspectorContentView: ScrollableStackXView {
    lazy var nodeTitleRowView: NodeTitleRowView = {
        let view = NodeTitleRowView(icon: "plus", name: "Some Node", locked: false)
        return view
    }()

    lazy var nodeTypeRowView: NodeTypeRowView = {
        let view = NodeTypeRowView()
        return view
    }()

    lazy var nodeInputsView: NodeInputsView = {
        let view = NodeInputsView(title: "Inputs", showPortButton: true)
        return view
    }()

    lazy var nodeOptionsView: NodeInputsView = {
        let view = NodeInputsView(title: "Options", showPortButton: false)
        return view
    }()

    lazy var nodeOutputsView: NodeOutputsView = {
        let view = NodeOutputsView()
        return view
    }()

    override func setupViews() {
        super.setupViews()

        self.stackView.addArrangedSubview(self.nodeTitleRowView)
        self.stackView.addArrangedSubview(self.nodeTypeRowView)
        self.stackView.addArrangedSubview(self.nodeInputsView)
        self.stackView.addArrangedSubview(self.nodeOutputsView)
        self.stackView.addArrangedSubview(self.nodeOptionsView)

        NSLayoutConstraint.activate([
            self.nodeTypeRowView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            self.nodeInputsView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            self.nodeOptionsView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            self.nodeOutputsView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}
