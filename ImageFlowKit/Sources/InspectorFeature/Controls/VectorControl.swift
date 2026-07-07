import Combine
import ComponentKit
import Helpers
import Values
import XKit

struct VectorControlConfiguration {
    var drag: NumberInput.DragConfiguration = .free(.init(fractionalDigits: 2))
    var formatter: FloatingPointFormatStyle<Double> = .default
    var labels: [String] = []
}

@MainActor
final class VectorControl: Control<[Double], VectorControlConfiguration, NumericControlContext>, WithRef {
    @PublishedEx var value: [Double] {
        didSet {
            if self.value != oldValue {
                self.inner.values = self.value
            }
        }
    }

    var context: NumericControlContext

    var configuration: VectorControlConfiguration {
        didSet {
            self.inner.dragConfiguration = self.configuration.drag
            self.inner.formatter = self.configuration.formatter
            if self.configuration.labels != oldValue.labels {
                self.inner.reloadLabels()
            }
        }
    }

    var view: XView {
        self.inner
    }

    lazy var inner: NumberInputArray = {
        NumberInputArray(
            self.value,
            formatter: self.configuration.formatter,
            style: .default
        )
        .labelForRow({ [weak self] index in
            self?.configuration.labels[tryGetAt: index] ?? "\(index)"
        })
        .onChange { [weak self] index, change in
            guard let self else { return }
            if self.value.indices.contains(index) {
                var oldValue = self.value
                oldValue[index] = change.oldValue
                self.value[index] = change.newValue
                self.onChange?(
                    .init(
                        newValue: self.value,
                        oldValue: oldValue,
                        commit: change.commit
                    )
                )
            }
        }
    }()

    var onChange: ((Change<[Double]>) -> ())?

    private var cancellables: Set<AnyCancellable> = []

    init(
        _ value: [Double],
        configuration: VectorControlConfiguration = .init(drag: .free(.init(fractionalDigits: 2))),
        context: NumericControlContext = .default,
    ) {
        self.value = value
        self.configuration = configuration
        self.context = context

        self.inner.$isDragging.sink { [weak self] isDragging in
            guard let self else { return }
            self.context.statusBarMessage(isDragging ? .statusMessageNumberDrag : nil)
        }.store(in: &self.cancellables)
    }

    func setDisabled(_ disabled: Bool) {
        self.inner.disabled = disabled
    }

    @discardableResult
    public func setDragConfiguration(for index: Int, _ config: NumberInput.DragConfiguration) -> Self {
        self.inner.setDragConfiguration(for: index, config)
        return self
    }
}
