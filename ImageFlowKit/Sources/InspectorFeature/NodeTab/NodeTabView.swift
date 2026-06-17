import Combine
import ComponentKit
import Helpers
import SharedModels
import XKit

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
        return view
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
    }

    func setupBindings() {
        let route = self.vm.$route

        self.contentUnavailableView.rx(route.map(\.isNode), kp: \.isHidden)
        self.contentView.rx(route.map(\.isContentUnavailable), kp: \.isHidden)

        self.nodeTitleView.rx(self.vm.$name, kp: \.name)
        self.nodeTitleView.rx(self.vm.$icon, kp: \.icon)
        self.nodeTitleView.rx(self.vm.$locked, kp: \.locked)
    }

    func setupNotifications() {
        self.vm.handleEvents(from: self.nodeTitleView.didEditNodeName.map({ .editName($0) }))
    }
}

