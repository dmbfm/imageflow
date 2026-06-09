import SharedModels
import XKit

final class CanvasInspectorView: ScrollableStackXView {

    struct ViewModel {
        var nodeCount: Int = 0
        var edgeCount: Int = 0
        var viewport: CanvasViewportModel = .init(origin: .zero, scale: 1.0)
    }

    var vm: ViewModel = .init() {
        didSet {
            self.update()
        }
    }

    lazy var titleRowView: XLabel = {
        let view = XLabel(labelWithString: "Canvas")
        view.font = .preferredFont(forTextStyle: .headline)
        view.lineBreakMode = .byTruncatingTail
        return view
    }()

    lazy var nodeCountRowView: BlockView = {
        let stack = XStackView(views: [
            {
                let view = XLabel(labelWithString: "Node Count")
                view.textColor = .secondaryLabelColor
                return view
            }(),
            XLabel(labelWithString: "22"),
        ])
        stack.orientation = .horizontal
        stack.distribution = .fill
        let view = BlockView(stack)
        return view
    }()

    lazy var edgeCountRowView: BlockView = {
        let stack = XStackView(views: [
            {
                let view = XLabel(labelWithString: "Edge Count")
                view.textColor = .secondaryLabelColor
                return view
            }(),
            XLabel(labelWithString: "48"),
        ])
        stack.orientation = .horizontal
        stack.distribution = .fill
        let view = BlockView(stack)
        return view
    }()

    lazy var positionRowView: NodeVectorInputControlView = {
        let view = NodeVectorInputControlView(label: "Viewport Position", value: .vector2(.init(x: 128.12, y: 50.0)))
        view.showPortButton = false
        // view.delegate = self
        // view.context = .init(NodeInspectorController, Int)
        return view
    }()

    override func setupViews() {
        super.setupViews()

        self.stackView.spacing = 8
        self.stackView.addArrangedSubview(self.titleRowView)
        self.stackView.addArrangedSubview(self.nodeCountRowView)
        self.stackView.addArrangedSubview(self.edgeCountRowView)
        self.stackView.addArrangedSubview(self.positionRowView)

        self.stackView.setCustomSpacing(16, after: self.titleRowView)

        NSLayoutConstraint.activate([
            self.nodeCountRowView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            self.edgeCountRowView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            self.positionRowView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor)
        ])
    }

    func update() {
        self.positionRowView.value = .vector2(.init(x: self.vm.viewport.origin.x, y: self.vm.viewport.origin.y))
    }
}
