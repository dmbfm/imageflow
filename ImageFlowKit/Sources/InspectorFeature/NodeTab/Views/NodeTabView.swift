import Combine
import Helpers
import SharedModels
import XKit

// MARK: - NodeTabView

final class NodeTabView: XView, Rx {

    var vm: NodeTabViewModel

    var cancellables: Set<AnyCancellable> = []

    lazy var contentUnavailableView: ContentUnavailableView = {
        ContentUnavailableView()
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    lazy var contentView: NodeTabContentView = {
        NodeTabContentView(self.vm.contentViewModel)
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    init(_ vm: NodeTabViewModel) {
        self.vm = vm

        super.init(frame: .zero)

        self.setupView()
        self.observe()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.addSubview(self.contentUnavailableView)
        self.addSubview(self.contentView)

        self.contentView.constraintToFillSuperview()
        self.contentUnavailableView.constraintToFillSuperview()
    }

    func observe() {
        self.contentUnavailableView.rx(self.vm.$state.map({ $0 == .nodeSelected }), kp: \.isHidden)
        self.contentView.rx(self.vm.$state.map({ $0 == .empty }), kp: \.isHidden)
    }

}

// MARK: - NodeTabView + ViewModel

extension NodeTabView {
    final class ContentUnavailableView: XView, Rx, WithRef {
        var cancellables: Set<AnyCancellable> = []

        lazy var label: NSTextField = {
            let view = NSTextField(labelWithString: "No Node Selected")
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = .systemFont(ofSize: 16)
            view.textColor = .secondaryLabelColor
            return view
        }()

        override init(frame: NSRect) {
            super.init(frame: frame)

            self.addSubview(self.label)

            NSLayoutConstraint.activate([
                self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override var intrinsicContentSize: NSSize {
            .init(width: Self.noIntrinsicMetric, height: self.label.intrinsicContentSize.height)
        }
    }
}
