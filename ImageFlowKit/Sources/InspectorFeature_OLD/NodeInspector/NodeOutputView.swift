import ComponentKit
import Values
import XKit

final class NodeOutputView: XView {

    var type: ValueType = .float {
        didSet {
            self.titleView.type = self.type
        }
    }

    var context: InspectorContext? {
        didSet {
            self.titleView.context = self.context
        }
    }

    var name: String {
        get { self.titleView.name }
        set { self.titleView.name = newValue }
    }

    var connected: Bool {
        get { self.titleView.connected }
        set { self.titleView.connected = newValue }
    }

    lazy var box: Box = {
        let view = block(self.titleView)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy private var titleView: TitleView = {
        .init()
    }()

    init() {
        super.init(frame: .zero)

        self.addSubview(self.box)
        self.box.constraintToFillSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class TitleView: NodePropertyTitleView {

    var context: InspectorContext?
    var type: ValueType = .float {
        didSet {
            self.typePillView.text = self.type.displayName
        }
    }

    lazy var typePillView: Pill = {
        let view = Pill(self.type.displayName)
        view.backgroundColor = .systemOrange.withAlphaComponent(0.82)
        return view
    }()

    override init() {
        super.init()
        self.stackView.alignment = .firstBaseline
        self.stackView.addArrangedSubview(self.typePillView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func onPortButtonClick() {
        self.context?.onPortClick?()
    }
}
