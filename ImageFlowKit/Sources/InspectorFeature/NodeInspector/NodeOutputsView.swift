import SharedModels
import Values
import XKit

final class NodeOutputsView: XViewEx {

    private(set) var outputViews: [NodeOutputView] = []

    lazy var stackView: XStackView = {
        let view = XStackView(views: [self.titleLabel])
        view.orientation = .vertical
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var titleLabel: XLabel = {
        var label = XLabel(labelWithString: "Outputs")
        label.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .bold)
        return label
    }()

    init() {
        super.init(frame: .zero)

        self.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Output Views

    func removeAllOutputViews() {
        for view in self.outputViews {
            view.removeFromSuperview()
        }
        self.outputViews.removeAll()
    }

    func addOutputView(forOutput output: FlowNode.Output) {
        let view = NodeOutputView.init()
        view.name = output.label
        view.connected = output.connected
        view.type = output.type
        self.addOutputView(view)
    }

    func addOutputView(_ view: NodeOutputView) {
        self.stackView.addArrangedSubview(view)
        self.outputViews.append(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}
