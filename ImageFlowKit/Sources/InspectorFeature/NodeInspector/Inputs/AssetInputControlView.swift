import Backend
import Helpers
import SwiftUI
import Values
import XKit

final class NodeAssetInputControlView: BaseNodeInputControlView {

    var assetButtonLabel: String {
        switch self.value {
        case .image(.asset(let id)), .lut(.asset(let id)): self.context?.displayName(forAsset: id) ?? "\(id)"
        case .image(.nodeOutput), .lut(.nodeOutput): ""
        default: "Select..."
        }
    }

    override var context: NodeInputControlContext? {
        didSet {
            self.update()
        }
    }

    lazy var stackView: XStackView = {
        let view = XStackView(views: [self.titleView, self.hstackView])
        view.orientation = .vertical
        return view
    }()

    lazy var hstackView: XStackView = {
        let view = XStackView(views: [self.assetButtonView, self.removeButtonView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.orientation = .horizontal
        view.distribution = .fill
        return view
    }()

    lazy var assetButtonView: XButton = {
        let view = XButton()
        view.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.tintProminence = .secondary
        view.target = self
        view.action = #selector(Self.assetButtonHandler)
        return view
    }()

    lazy var removeButtonView: XButton = {
        let view = XButton()
        view.image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: nil)
        view.isBordered = false
        view.target = self
        view.action = #selector(Self.removeButtonHandler)
        return view
    }()

    override init(label: String, value: Value, connected: Bool = false) {
        super.init(label: label, value: value, connected: connected)
        self.blockView.content = self.stackView

        NSLayoutConstraint.activate([
            self.titleView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor),
            self.hstackView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor),
        ])

        self.update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update() {
        self.assetButtonView.title = self.assetButtonLabel
    }

    @objc func assetButtonHandler() {
        self.context?.onEvent(.openAssetPicker)
    }

    @objc func removeButtonHandler() {
        let newValue = self.value.type.defaultValue
        if self.value != newValue {
            self.setValue(newValue: newValue, oldValue: self.value, commit: true)
        }
    }
}
