import SwiftUI
import XKit

class NodeInspectorContentView: XViewEx {

    lazy var scrollView: XScrollView = {
        class ClipView: NSClipView { override var isFlipped: Bool { true } }
        let view = XScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentView = ClipView()
        view.documentView = self.stackView
        view.drawsBackground = false
        return view
    }()

    lazy var stackView: XStackView = {
        let view = XStackView(views: [
            self.nodeTitleRowView,
            self.nodeTypeRowView,
            self.nodeInputsView,
            self.nodeOutputsView,
            self.nodeOptionsView,
        ])

        view.orientation = .vertical
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 16

        return view
    }()

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

    override init(frame: NSRect) {
        super.init(frame: frame)
        self.setupViews()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.addSubview(self.scrollView)
        NSLayoutConstraint.activateConstraint(self.scrollView, toFill: self)
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
        ])
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
