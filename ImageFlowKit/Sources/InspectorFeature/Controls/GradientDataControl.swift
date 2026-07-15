import Combine
import ComponentKit
import Helpers
import Values
import XKit

@MainActor
final class GradientDataControl: Control<GradientData, (), ()> {
    @PublishedEx var value: Values.GradientData {
        didSet {
            self.gradientDataEditorView.value = self.value
        }
    }

    var configuration: ()

    var context: ()

    var view: XView {
        self.gradientDataEditorView
    }

    lazy var gradientDataEditorView: GradientDataEditor = {
        GradientDataEditor(self.value)
            .with(
                \.onChange,
                { [unowned self] change in
                    self.onChange?(
                        .init(
                            newValue: change.newValue,
                            oldValue: change.oldValue,
                            commit: change.commit
                        )
                    )
                }
            )
    }()

    var onChange: ((Change<Values.GradientData>) -> ())?

    init(_ value: GradientData) {
        self.value = value
    }

    func setDisabled(_ disabled: Bool) {
    }
}
