import Controls
import Values
import XKit

final class NodeColorInputControlView: BaseNodeInputControlView {

    var colorValue: Color4 {
        self.value.maybeColor4 ?? .black
    }

    lazy var stackView: XStackView = {
        let view = XStackView(views: [self.titleView, self.colorPickerView])
        view.orientation = .vertical
        view.alignment = .leading
        return view
    }()

    lazy var colorPickerView: ColorPickerPlatformView = {
        let view = ColorPickerPlatformView()
        view.color = self.colorValue.nsColor
        view.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .didChange(let change):
                guard let newValue = Color4(nsColor: change.newValue) else { return }
                guard self.colorValue != newValue else { return }
                self.setValue(
                    newValue: .color4(newValue),
                    oldValue: self.value,
                    commit: true
                )
                break
            }
        }
        return view
    }()

    override init(label: String, value: Value, connected: Bool = false) {
        super.init(label: label, value: value, connected: connected)
        self.blockView.view = self.stackView
        NSLayoutConstraint.activate([
            self.colorPickerView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor),
            self.titleView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor),
        ])
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update() {
        self.colorPickerView.color = self.colorValue.nsColor
    }
}
