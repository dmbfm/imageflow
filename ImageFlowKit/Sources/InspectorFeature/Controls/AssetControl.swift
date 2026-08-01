import Combine
import ComponentKit
import Helpers
import Values
import XKit

struct AssetControlContext {
    var openAssetPicker: () -> ()
    var titleForAsset: (UUID) -> String?
}

@MainActor
final class AssetControl: Control<Optional<AssetIdentifier>, (), AssetControlContext> {
    var value: Optional<AssetIdentifier> {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var configuration: ()

    var context: AssetControlContext

    var view: XKit.XView {
        self.stackView
    }

    var onChange: ((Change<Optional<AssetIdentifier>>) -> ())?

    var label: String {
        switch self.value {
        case .asset(let id): self.context.titleForAsset(id) ?? "\(id)"
        case .nodeOutput: ""
        case .none: "Select..."
        }
    }

    lazy var stackView: HStack = {
        HStack(
            spacing: 4,
            views: [
                self.button,
                self.removeButton,
            ]
        )
    }()

    lazy var button: Button = {
        Button("Select...") { [weak self] in self?.onClick() }
            .with(\.tintProminence, .secondary)
            .withContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
            .withContentHuggingPriority(.defaultLow - 1, for: .horizontal)
    }()

    lazy var removeButton: Button = {
        Button(
            "",
            systemSymbolName: "xmark.circle.fill",
            buttonSize: .regular,
            tint: nil
        ) { [weak self] in
            guard let self else { return }
            self.onChange?(.init(newValue: nil, oldValue: self.value, commit: true))
        }
        .with(\.isBordered, false)
    }()

    init(_ value: AssetIdentifier?, context: AssetControlContext) {
        self.value = value
        self.context = context

        self.update()
    }

    func setDisabled(_ disabled: Bool) {
        self.button.isHidden = disabled
        self.update()
    }

    func onClick() {
        self.context.openAssetPicker()
    }

    func update() {
        self.button.title = self.label
        self.removeButton.isHidden = self.value == nil || self.button.isHidden
    }
}
