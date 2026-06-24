import Combine
import ComponentKit
import Helpers
import Values
import XKit

@MainActor
final class ColorControl: Control<XColor, (), ()> {
    var configuration: ()

    var context: ()

    var onChange: ((Change<XColor>) -> ())?

    @PublishedEx var value: XColor {
        didSet {
            if self.colorPickerView.color != self.value {
                self.colorPickerView.color = self.value
            }
        }
    }

    var view: XView {
        self.colorPickerView
    }

    lazy var colorPickerView: ColorPicker = {
        ColorPicker(self.value)
            .onChange({ [weak self] newValue in
                guard let self else { return }
                let oldValue = self.value
                self.value = newValue
                self.onChange?(
                    .init(
                        newValue: newValue,
                        oldValue: oldValue,
                        commit: true
                    )
                )
            })
    }()

    init(_ value: XColor) {
        self.value = value
    }

    func setDisabled(_ disabled: Bool) {
        self.colorPickerView.disabled = disabled
    }
}
