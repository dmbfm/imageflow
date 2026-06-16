import ComponentKit
import Values
import XKit

final class NodeInputsView: XView {

    let title: String

    let showPortButton: Bool

    private(set) var inputViews: [any NodeInputControlView] = []

    lazy var stackView: VStack = {
        let view = VStack(alignment: .fill, views: [self.titleLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 6
        return view
    }()

    lazy var titleLabel: Label = {
        var label = Label(self.title)
        label.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .bold)
        return label
    }()

    init(title: String = "Inputs", showPortButton: Bool = true) {
        self.title = title
        self.showPortButton = showPortButton

        super.init(frame: .zero)
        self.addSubview(self.stackView)

        NSLayoutConstraint.activateConstraint(self.stackView, toFill: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Input Views

    func removeAllInputViews() {
        for view in self.inputViews {
            view.superview?.removeFromSuperview()
        }
        self.inputViews.removeAll()
    }

    func addInputView(_ view: any NodeInputControlView) {
        view.showPortButton = self.showPortButton
        self.stackView.addView(view)
        self.inputViews.append(view)
    }
}

#Preview {
    NodeInputsView()
}
