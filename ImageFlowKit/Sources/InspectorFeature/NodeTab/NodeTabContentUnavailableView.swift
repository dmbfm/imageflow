import Combine
import Helpers
import XKit

final class NodeTabContentUnavailableView: XView, Rx, WithRef {
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
