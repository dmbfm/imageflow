import Combine
import ComponentKit
import Helpers
import Values
import XKit

struct MatrixControlConfiguration {
    var drag: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2))
    var formatter: FloatingPointFormatStyle<Double> = .default
}

@MainActor
final class MatrixControl: Control<[Double], MatrixControlConfiguration, NumericControlContext>, WithRef {
    @PublishedEx var value: [Double] {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var onChange: ((Change<[Double]>) -> ())?

    var context: NumericControlContext

    var configuration: MatrixControlConfiguration {
        didSet {
            for input in self.numberInputs {
                input.dragConfiguration = self.configuration.drag
                input.formatter = self.configuration.formatter
            }
        }
    }

    var view: XView {
        self.inner
    }

    private let dim: Int

    private var cancellables: Set<AnyCancellable> = []

    lazy var inner: RegularGrid = {
        RegularGrid(self.dim, verticalSpacing: 4, horizontalSpacing: 4, views: self.numberInputs)
    }()

    lazy var numberInputs: [NumberInput] = {
        var views: [NumberInput] = []
        for i in 0..<(self.dim * self.dim) {
            let view = NumberInput(
                self.value[i],
                formatter: self.configuration.formatter,
                style: .default
            )
            .with(\.sensitivityResolver, SensitivityResolver.shared)
            .onChange({ [weak self] change in self?.onNumberInputChange(i, change) })
            .with(\.dragConfiguration, self.configuration.drag)
            view.setContentCompressionResistancePriority(.defaultLow - 10, for: .horizontal)
            view.$isDragging.sink { [weak self] isDragging in
                self?.context.statusBarMessage(isDragging ? .statusMessageNumberDrag : nil)
            }.store(in: &self.cancellables)
            views.append(view)
        }
        return views
    }()

    func onNumberInputChange(_ index: Int, _ change: NumberInput.Change) {
        var oldValue = self.value
        oldValue[index] = change.oldValue
        self.value[index] = change.newValue
        self.onChange?(.init(newValue: self.value, oldValue: oldValue, commit: change.commit))
    }

    init?(_ value: [Double], configuration: MatrixControlConfiguration, context: Context) {
        self.value = value
        self.configuration = configuration
        self.context = context
        self.dim =
            switch value.count {
            case 4: 2
            case 9: 3
            case 16: 4
            case 25: 5
            case 36: 6
            case 49: 7
            default: 0
            }
        if self.dim == 0 {
            return nil
        }
    }

    func setDisabled(_ disabled: Bool) {
        for input in self.numberInputs {
            input.isEnabled = !disabled
        }
    }

    func update() {
        for (index, view) in self.numberInputs.enumerated() {
            if view.value != self.value[index] {
                view.value = self.value[index]
            }
        }
    }
}
