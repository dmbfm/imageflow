import Combine
import ComponentKit
import Helpers
import SharedModels
import Values
import XKit

struct PickerControlConfiguration: Equatable {
    let options: [String]
}

@MainActor
final class PickerControl: Control<Int, PickerControlConfiguration, ()> {
    @PublishedEx var value: Int {
        didSet {
            if self.value != oldValue {
                self.pickerView.selected = self.value
            }
        }
    }

    var configuration: PickerControlConfiguration {
        didSet {
            if self.configuration != oldValue {
                self.pickerView.options = self.configuration.options
            }
        }
    }

    var context: ()

    var view: XView {
        self.pickerView
    }

    var onChange: ((Change<Int>) -> ())?

    lazy var pickerView: Picker = {
        Picker(self.configuration.options, selected: self.value)
            .onChange { [weak self] newValue in
                guard let self else { return }
                guard self.value != newValue else { return }
                let oldValue = self.value
                self.value = Int(newValue)
                self.onChange?(
                    .init(
                        newValue: newValue,
                        oldValue: oldValue,
                        commit: true
                    )
                )
            }
    }()

    init(_ value: Int, configuration: PickerControlConfiguration = .init(options: [])) {
        self.value = value
        self.configuration = configuration
    }

    func setDisabled(_ disabled: Bool) {
        self.pickerView.disabled = disabled
    }
}
