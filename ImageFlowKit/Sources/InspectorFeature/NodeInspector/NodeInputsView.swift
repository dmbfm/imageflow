import Values
import XKit

final class NodeInputsView: XViewEx {

    private(set) var inputViews: [any NodeInputControlView] = []

    lazy var stackView: XStackView = {
        let view = XStackView(views: [self.titleLabel])
        view.orientation = .vertical
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var titleLabel: XLabel = {
        var label = XLabel(labelWithString: "Inputs")
        label.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .bold)
        return label
    }()

    init() {
        super.init(frame: .zero)

        // self.withLayer({
        //     $0.borderWidth = 1
        //     $0.borderColor = XColor.systemRed.withAlphaComponent(0.2).cgColor
        // })

        self.addSubview(self.stackView)

        NSLayoutConstraint.activateConstraint(self.stackView, toFill: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Input Views

    func removeAllInputViews() {
        for view in self.inputViews {
            view.removeFromSuperview()
        }
        self.inputViews.removeAll()
    }

    func addInputView(_ view: any NodeInputControlView) {
        self.stackView.addArrangedSubview(view)
        self.inputViews.append(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}

#Preview {
    NodeInputsView()
}
