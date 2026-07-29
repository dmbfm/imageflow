import Combine
import ComponentKit
import Helpers
import Values
import XKit

@MainActor
final class AffineTransformControl: Control<[Double], MatrixControlConfiguration, NumericControlContext> {
    @PublishedEx var value: [Double] {
        didSet {
            if self.value != oldValue && self.value.count >= 6 {
                self.matrixControl.value.replaceSubrange(0...3, with: self.value[0...3])
                self.vectorControl.value.replaceSubrange(0...1, with: self.value[4...5])
            }
        }
    }

    var configuration: MatrixControlConfiguration

    var context: NumericControlContext

    var view: XKit.XView {
        VStack(
            spacing: 4,
            views: [
                Padded(self.matrixControl.view, insets: .init(top: 0, left: 20, bottom: 0, right: 0)),
                self.vectorControl.view,
            ]
        )
    }

    lazy var matrixControl: MatrixControl = {
        .init(Array(self.value[0...3]), configuration: self.configuration, context: self.context)!
            .with(
                \.onChange,
                { [unowned self] change in
                    let oldValue = self.value
                    self.value.replaceSubrange(0...3, with: change.newValue)
                    self.onChange?(.init(newValue: self.value, oldValue: oldValue, commit: change.commit))
                }
            )
    }()

    lazy var vectorControl: VectorControl = {
        .init(
            Array(self.value[4...5]),
            configuration: .init(
                drag: self.configuration.drag,
                formatter: self.configuration.formatter,
                labels: ["tx", "ty"]
            ),
            context: self.context
        ).with(
            \.onChange,
            { [unowned self] change in
                let oldValue = self.value
                self.value.replaceSubrange(4...5, with: change.newValue)
                self.onChange?(.init(newValue: self.value, oldValue: oldValue, commit: change.commit))
            }
        )
    }()

    var onChange: ((Change<[Double]>) -> ())?

    init(_ value: [Double], configuration: Configuration, context: Context) {
        self.value = value
        self.configuration = configuration
        self.context = context
    }

    func setDisabled(_ disabled: Bool) {
        self.matrixControl.setDisabled(disabled)
        self.vectorControl.setDisabled(disabled)
    }
}
